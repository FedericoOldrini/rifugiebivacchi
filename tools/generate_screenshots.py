#!/usr/bin/env python3
"""
Screenshot Overlay & Resize — Rifugi e Bivacchi

Design moderno per App Store: canvas colorato in alto con testo grande,
screenshot ridimensionato con angoli arrotondati e ombra nella parte bassa.

Questo script viene invocato da Fastlane con:
    python3 tools/generate_screenshots.py --skip-test

I raw screenshot devono già essere presenti in screenshots/raw/<device_name>/.
Vengono catturati da simulatori iOS reali tramite capture_screenshots.sh --all.

Requisiti:
- Python 3.7+
- Pillow (PIL): pip3 install Pillow

Uso:
    python3 tools/generate_screenshots.py --skip-test        # Overlay + resize su raw esistenti
    python3 tools/generate_screenshots.py --skip-test --no-resize  # Solo overlay, senza resize
"""

import sys
import argparse
from pathlib import Path
from typing import Optional, Tuple

try:
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
except ImportError:
    print("❌ Pillow non trovato. Installa con: pip3 install Pillow")
    sys.exit(1)

# Configurazione
PROJECT_ROOT = Path(__file__).parent.parent
RAW_DIR = PROJECT_ROOT / "screenshots" / "raw"
FINAL_DIR = PROJECT_ROOT / "screenshots" / "final"

# Dimensioni App Store richieste
APP_STORE_SIZES = {
    "iPhone_6_9": (1320, 2868),
    "iPhone_6_7": (1290, 2796),
    "iPhone_6_5": (1242, 2688),
    "iPhone_5_5": (1242, 2208),
    "iPad_Pro_13": (2064, 2752),
    "iPad_Pro_12_9": (2048, 2732),
}

# Mapping per le dimensioni legacy: quale device nativo usare come source per il resize
LEGACY_SIZE_SOURCE = {
    "iPhone_5_5": "iPhone_6_5",
    "iPad_Pro_12_9": "iPad_Pro_13",
}

# Configurazione screenshot (deve matchare i nomi nel golden test)
SCREENSHOTS_CONFIG = {
    "01_lista_rifugi": {
        "title": "Scopri oltre\n1000 rifugi",
        "subtitle": "Database completo CAI\ncon informazioni dettagliate",
    },
    "02_mappa": {
        "title": "Mappa\nintelligente",
        "subtitle": "Trova i rifugi più vicini\ncon clustering avanzato",
    },
    "03_dettaglio_rifugio": {
        "title": "Tutte le info\nche cerchi",
        "subtitle": "Contatti, servizi,\naltitudine e foto",
    },
    "04_profilo": {
        "title": "Il tuo profilo\nalpinista",
        "subtitle": "Tieni traccia dei rifugi\nvisitati e preferiti",
    },
    "05_passaporto": {
        "title": "Passaporto\ndei Rifugi",
        "subtitle": "Registra le tue visite\ne colleziona i timbri",
    },
}

# ─── Colori ───────────────────────────────────────────────────────────────────
# deepTeal brand color = #2C5F5D = RGB(44, 95, 93)
BG_COLOR_TOP = (32, 75, 73)  # Leggermente più scuro in alto
BG_COLOR_BOTTOM = (44, 95, 93)  # deepTeal originale in basso
TEXT_COLOR = (255, 255, 255)  # Bianco puro per titolo
SUBTITLE_COLOR = (189, 224, 221)  # Teal chiarissimo per sottotitolo

# ─── Layout (proporzioni rispetto all'altezza totale) ────────────────────────
# I valori vengono adattati in base all'aspect ratio del device.
# iPhone moderni (~2.17 h/w): testo compatto, screenshot grande
# iPhone 5.5" (~1.78 h/w): bilanciato
# iPad (~1.33 h/w): più spazio al testo, screenshot più piccolo
CORNER_RADIUS_RATIO = 0.025  # Raggio angoli arrotondati (% della larghezza)
SHADOW_OFFSET = 8  # Offset ombra in px (verrà scalato)
SHADOW_BLUR = 25  # Blur ombra in px (verrà scalato)


def get_layout_params(width: int, height: int) -> dict:
    """Calcola i parametri di layout adattivi in base all'aspect ratio."""
    aspect = height / width

    if aspect >= 2.0:
        # iPhone moderni (6.9", 6.7", 6.5") — aspect ~2.17
        return {
            "text_area_ratio": 0.30,
            "screenshot_ratio": 0.74,
            "screenshot_top_offset": 0.28,
            "title_font_ratio": 0.080,
            "subtitle_font_ratio": 0.038,
            "text_y_start_ratio": 0.15,  # % della text_area
            "text_gap_ratio": 0.015,  # Gap titolo-sottotitolo (% altezza)
            "side_margin_ratio": 0.05,
        }
    elif aspect >= 1.6:
        # iPhone 5.5" — aspect ~1.78
        return {
            "text_area_ratio": 0.30,
            "screenshot_ratio": 0.72,
            "screenshot_top_offset": 0.30,
            "title_font_ratio": 0.078,
            "subtitle_font_ratio": 0.036,
            "text_y_start_ratio": 0.12,
            "text_gap_ratio": 0.012,
            "side_margin_ratio": 0.05,
        }
    else:
        # iPad (~1.33) — aspect quasi quadrato, serve più spazio testo
        return {
            "text_area_ratio": 0.26,
            "screenshot_ratio": 0.72,
            "screenshot_top_offset": 0.26,
            "title_font_ratio": 0.065,
            "subtitle_font_ratio": 0.030,
            "text_y_start_ratio": 0.15,
            "text_gap_ratio": 0.010,
            "side_margin_ratio": 0.06,
        }


# ─── Font ─────────────────────────────────────────────────────────────────────
# SF Pro (System Font) su macOS — fallback a Helvetica Neue → Helvetica
FONT_PATHS = [
    "/System/Library/Fonts/SFNS.ttf",  # SF Pro (San Francisco)
    "/System/Library/Fonts/SFNSRounded.ttf",  # SF Rounded
    "/System/Library/Fonts/HelveticaNeue.ttc",  # Helvetica Neue
    "/System/Library/Fonts/Helvetica.ttc",  # Helvetica (fallback)
]
TITLE_FONT_RATIO = 0.080  # Dimensione titolo = 8% della larghezza
SUBTITLE_FONT_RATIO = 0.038  # Dimensione sottotitolo = 3.8% della larghezza
TITLE_STROKE_WIDTH = 1  # Simulazione bold (stroke width in px, scalato)


def print_header(text: str):
    """Stampa intestazione"""
    print(f"\n{'=' * 70}")
    print(f"🏔️  {text}")
    print(f"{'=' * 70}\n")


def load_font(size: int):
    """Carica il miglior font disponibile nel sistema."""
    for font_path in FONT_PATHS:
        try:
            return ImageFont.truetype(font_path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def create_gradient_background(
    width: int, height: int, area_height: int
) -> Image.Image:
    """Crea uno sfondo con gradiente verticale nel banner superiore.

    Il gradiente va da BG_COLOR_TOP (in alto) a BG_COLOR_BOTTOM (in basso nel banner),
    poi continua con BG_COLOR_BOTTOM per il resto del canvas.
    """
    canvas = Image.new("RGB", (width, height), BG_COLOR_BOTTOM)
    draw = ImageDraw.Draw(canvas)

    for y in range(area_height):
        t = y / max(area_height - 1, 1)
        r = int(BG_COLOR_TOP[0] + (BG_COLOR_BOTTOM[0] - BG_COLOR_TOP[0]) * t)
        g = int(BG_COLOR_TOP[1] + (BG_COLOR_BOTTOM[1] - BG_COLOR_TOP[1]) * t)
        b = int(BG_COLOR_TOP[2] + (BG_COLOR_BOTTOM[2] - BG_COLOR_TOP[2]) * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    return canvas


def round_corners(image: Image.Image, radius: int) -> Image.Image:
    """Applica angoli arrotondati a un'immagine."""
    mask = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), image.size], radius=radius, fill=255)
    result = image.copy()
    result.putalpha(mask)
    return result


def add_shadow(image: Image.Image, offset: int, blur: int, shadow_color=(0, 0, 0, 80)):
    """Aggiunge un'ombra sotto un'immagine con trasparenza (RGBA).
    Restituisce (immagine_con_ombra, extra_padding)."""
    # Crea canvas più grande per l'ombra
    extra = blur * 3
    w, h = image.size
    shadow_canvas = Image.new("RGBA", (w + extra * 2, h + extra * 2), (0, 0, 0, 0))

    # Crea la forma dell'ombra dal canale alpha dell'immagine
    shadow_shape = Image.new("RGBA", image.size, shadow_color)
    # Usa l'alpha dell'immagine originale come maschera per l'ombra
    shadow_shape.putalpha(image.split()[3])

    # Posiziona l'ombra con offset
    shadow_canvas.paste(shadow_shape, (extra + offset, extra + offset))

    # Applica blur
    shadow_canvas = shadow_canvas.filter(ImageFilter.GaussianBlur(radius=blur))

    # Sovrapponi l'immagine originale centrata
    shadow_canvas.paste(image, (extra, extra), image)

    return shadow_canvas, extra


def draw_multiline_text_centered(
    draw, text, x_center, y_start, font, fill, stroke_width=0, line_spacing=1.15
):
    """Disegna testo multiline centrato orizzontalmente, restituisce l'altezza totale usata."""
    lines = text.split("\n")
    total_height = 0

    # Calcola altezza di ogni riga
    line_heights = []
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font, stroke_width=stroke_width)
        h = bbox[3] - bbox[1]
        line_heights.append(h)

    y = y_start
    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=font, stroke_width=stroke_width)
        line_width = bbox[2] - bbox[0]
        line_height = line_heights[i]
        x = x_center - line_width // 2

        if stroke_width > 0:
            # Disegna con stroke per effetto bold
            draw.text(
                (x, y),
                line,
                font=font,
                fill=fill,
                stroke_width=stroke_width,
                stroke_fill=fill,
            )
        else:
            draw.text((x, y), line, font=font, fill=fill)

        y += int(line_height * line_spacing)
        total_height = y - y_start

    return total_height


def add_overlay(
    input_path: Path,
    output_path: Path,
    title: str,
    subtitle: str,
    target_size: Optional[Tuple[int, int]] = None,
) -> bool:
    """Crea screenshot per App Store con design moderno.

    Layout:
    ┌─────────────────────────┐
    │    Sfondo deepTeal      │ ← gradiente
    │                         │
    │    TITOLO GRANDE         │ ← SF Pro, bianco, bold
    │    Sottotitolo           │ ← SF Pro, teal chiaro
    │                         │
    │  ┌───────────────────┐  │
    │  │                   │  │ ← Screenshot con angoli
    │  │   Screenshot      │  │    arrotondati e ombra
    │  │   dell'app        │  │
    │  │                   │  │
    │  │                   │  │
    │  └───────────────────┘  │
    └─────────────────────────┘
    """
    try:
        img = Image.open(input_path)

        # Dimensioni target finali
        if target_size:
            final_w, final_h = target_size
        else:
            final_w, final_h = img.size

        # Scala proporzionale per adattare i parametri
        scale = final_w / 1320  # Normalizzato su iPhone 6.9" (1320px)

        # ─── Layout adattivo ──────────────────────────────────────────
        layout = get_layout_params(final_w, final_h)

        # ─── Font ─────────────────────────────────────────────────────
        title_font_size = max(int(final_w * layout["title_font_ratio"]), 20)
        subtitle_font_size = max(int(final_w * layout["subtitle_font_ratio"]), 14)
        title_font = load_font(title_font_size)
        subtitle_font = load_font(subtitle_font_size)
        stroke_w = max(1, int(TITLE_STROKE_WIDTH * scale))

        # ─── Layout dimensioni ────────────────────────────────────────
        text_area_h = int(final_h * layout["text_area_ratio"])
        screenshot_h = int(final_h * layout["screenshot_ratio"])
        screenshot_top = int(final_h * layout["screenshot_top_offset"])
        corner_radius = int(final_w * CORNER_RADIUS_RATIO)
        shadow_offset = max(4, int(SHADOW_OFFSET * scale))
        shadow_blur = max(10, int(SHADOW_BLUR * scale))
        side_margin = int(final_w * layout["side_margin_ratio"])

        # ─── Sfondo con gradiente ─────────────────────────────────────
        canvas = create_gradient_background(final_w, final_h, text_area_h)
        canvas_rgba = canvas.convert("RGBA")

        # ─── Testo ────────────────────────────────────────────────────
        draw = ImageDraw.Draw(canvas_rgba)

        # Posizione verticale del testo: centrato nel banner
        text_y_start = int(text_area_h * layout["text_y_start_ratio"])
        x_center = final_w // 2

        # Titolo
        title_total_h = draw_multiline_text_centered(
            draw,
            title,
            x_center,
            text_y_start,
            title_font,
            TEXT_COLOR,
            stroke_width=stroke_w,
            line_spacing=1.12,
        )

        # Sottotitolo (sotto il titolo con un po' di spacing)
        subtitle_y = (
            text_y_start + title_total_h + int(final_h * layout["text_gap_ratio"])
        )
        draw_multiline_text_centered(
            draw,
            subtitle,
            x_center,
            subtitle_y,
            subtitle_font,
            SUBTITLE_COLOR,
            stroke_width=0,
            line_spacing=1.18,
        )

        # ─── Screenshot con angoli arrotondati ────────────────────────
        # Ridimensiona lo screenshot per stare nel canvas
        screenshot_display_w = final_w - (side_margin * 2)
        screenshot_display_h = screenshot_h

        # Mantieni aspect ratio dello screenshot
        img_aspect = img.width / img.height
        target_aspect = screenshot_display_w / screenshot_display_h

        if img_aspect > target_aspect:
            # Screenshot più largo: adatta alla larghezza
            new_w = screenshot_display_w
            new_h = int(new_w / img_aspect)
        else:
            # Screenshot più alto: adatta all'altezza
            new_h = screenshot_display_h
            new_w = int(new_h * img_aspect)

        img_resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)

        # Angoli arrotondati
        img_rounded = round_corners(img_resized, corner_radius)

        # Ombra
        img_with_shadow, shadow_extra = add_shadow(
            img_rounded,
            shadow_offset,
            shadow_blur,
            shadow_color=(0, 0, 0, 60),
        )

        # ─── Compositing finale ───────────────────────────────────────
        # Centra lo screenshot orizzontalmente
        paste_x = (final_w - img_with_shadow.width) // 2
        paste_y = screenshot_top - shadow_extra

        # Assicurati che lo screenshot non esca dal canvas in basso
        max_paste_y = final_h - img_with_shadow.height
        paste_y = min(paste_y, max_paste_y)

        canvas_rgba = Image.alpha_composite(
            canvas_rgba,
            Image.new("RGBA", canvas_rgba.size, (0, 0, 0, 0)),
        )

        # Incolla screenshot con ombra
        temp = Image.new("RGBA", canvas_rgba.size, (0, 0, 0, 0))
        temp.paste(img_with_shadow, (paste_x, paste_y), img_with_shadow)
        canvas_rgba = Image.alpha_composite(canvas_rgba, temp)

        # ─── Salva ────────────────────────────────────────────────────
        final = canvas_rgba.convert("RGB")
        output_path.parent.mkdir(parents=True, exist_ok=True)
        final.save(output_path, "PNG", quality=95, optimize=True)

        return True

    except Exception as e:
        print(f"   ❌ Errore overlay: {e}")
        import traceback

        traceback.print_exc()
        return False


def has_multi_device_raw() -> bool:
    """Verifica se gli screenshot raw sono organizzati per device (multi-device mode)."""
    if not RAW_DIR.exists():
        return False
    for subdir in RAW_DIR.iterdir():
        if subdir.is_dir() and subdir.name in APP_STORE_SIZES:
            if list(subdir.glob("*.png")):
                return True
    return False


def process_overlays_multi_device() -> int:
    """Applica overlay usando screenshot raw per-device."""
    processed = 0

    for size_name, target_dims in APP_STORE_SIZES.items():
        if size_name in LEGACY_SIZE_SOURCE:
            source_size = LEGACY_SIZE_SOURCE[size_name]
            source_dir = RAW_DIR / source_size
            label = f"(resize da {source_size})"
        else:
            source_dir = RAW_DIR / size_name
            label = "(nativo)"

        if not source_dir.exists() or not list(source_dir.glob("*.png")):
            print(
                f"   ⚠️  Nessun raw trovato per {size_name} in {source_dir.relative_to(PROJECT_ROOT)}"
            )
            continue

        print(f"\n   📐 {size_name} {target_dims[0]}×{target_dims[1]} {label}")

        for screenshot_path in sorted(source_dir.glob("*.png")):
            config = None
            for key, cfg in SCREENSHOTS_CONFIG.items():
                if key in screenshot_path.stem:
                    config = cfg
                    break

            if not config:
                continue

            output_path = FINAL_DIR / size_name / screenshot_path.name
            if add_overlay(
                screenshot_path,
                output_path,
                config["title"],
                config["subtitle"],
                target_size=target_dims,
            ):
                print(f"      ✅ {screenshot_path.name}")
                processed += 1

    return processed


def process_overlays_single_device(resize: bool = True) -> int:
    """Applica overlay a screenshot raw flat (fallback se non organizzati per device)."""
    screenshots = list(RAW_DIR.glob("*.png")) if RAW_DIR.exists() else []

    if not screenshots:
        print(f"   ❌ Nessun screenshot trovato in {RAW_DIR}")
        return 0

    print(f"   Trovati {len(screenshots)} screenshot")
    processed = 0

    for screenshot_path in sorted(screenshots):
        config = None
        for key, cfg in SCREENSHOTS_CONFIG.items():
            if key in screenshot_path.stem:
                config = cfg
                break

        if not config:
            print(f"   ⚠️  Config non trovata per: {screenshot_path.name}")
            continue

        if resize:
            for size_name, size_dims in APP_STORE_SIZES.items():
                output_path = FINAL_DIR / size_name / screenshot_path.name
                if add_overlay(
                    screenshot_path,
                    output_path,
                    config["title"],
                    config["subtitle"],
                    target_size=size_dims,
                ):
                    print(f"   ✅ {size_name}/{screenshot_path.name}")
                    processed += 1
        else:
            output_path = FINAL_DIR / screenshot_path.name
            if add_overlay(
                screenshot_path, output_path, config["title"], config["subtitle"]
            ):
                print(f"   ✅ {screenshot_path.name}")
                processed += 1

    return processed


def process_overlays(resize: bool = True) -> int:
    """Applica overlay, scegliendo automaticamente tra multi-device e single-device."""
    if has_multi_device_raw():
        print("   📱 Modalità multi-device: screenshot nativi per ogni dimensione")
        return process_overlays_multi_device()
    else:
        print("   📱 Modalità single-device: resize da un unico set di raw")
        return process_overlays_single_device(resize=resize)


def main():
    parser = argparse.ArgumentParser(
        description="Applica overlay e ridimensiona screenshot per App Store"
    )
    parser.add_argument(
        "--skip-test",
        action="store_true",
        help="Usa screenshot raw esistenti (standard per Fastlane)",
    )
    parser.add_argument(
        "--no-resize",
        action="store_true",
        help="Non ridimensionare per tutte le dimensioni App Store",
    )
    args = parser.parse_args()

    print_header("Screenshot Overlay — Rifugi e Bivacchi")

    if not args.skip_test:
        print("❌ La cattura diretta è stata rimossa da questo script.")
        print("   Usa il capture script per catturare screenshot da simulatore:")
        print("   tools/capture_screenshots.sh --all")
        print()
        print("   Oppure usa --skip-test per applicare overlay a raw esistenti.")
        sys.exit(1)

    # Verifica che ci siano raw screenshot
    if not RAW_DIR.exists():
        print(f"❌ Directory raw non trovata: {RAW_DIR}")
        print(f"   Esegui prima la cattura da simulatore:")
        print(f"   tools/capture_screenshots.sh --all")
        sys.exit(1)

    # Applica overlay e ridimensionamento
    processed = process_overlays(resize=not args.no_resize)

    if processed == 0:
        print("\n⚠️  Nessun screenshot processato!")
        print(f"   Verifica che ci siano screenshot .png in {RAW_DIR}")
        print(f"   con nomi che contengono: {', '.join(SCREENSHOTS_CONFIG.keys())}")
        sys.exit(1)

    print(f"\n   ✅ {processed} screenshot finali generati")

    # Riepilogo
    print_header("Completato!")

    if RAW_DIR.exists():
        raw_per_device = list(RAW_DIR.rglob("*.png"))
        if has_multi_device_raw():
            print(f"📁 Screenshot raw:   {RAW_DIR} ({len(raw_per_device)} file)")
            for subdir in sorted(RAW_DIR.iterdir()):
                if subdir.is_dir() and list(subdir.glob("*.png")):
                    count = len(list(subdir.glob("*.png")))
                    print(f"   └── {subdir.name}/ ({count} screenshot)")
        else:
            raw_flat = list(RAW_DIR.glob("*.png"))
            print(f"📁 Screenshot raw:   {RAW_DIR} ({len(raw_flat)} file)")

    if FINAL_DIR.exists():
        final_count = len(list(FINAL_DIR.rglob("*.png")))
        print(f"📁 Screenshot finali: {FINAL_DIR} ({final_count} file)")
        for size_dir in sorted(FINAL_DIR.iterdir()):
            if size_dir.is_dir():
                count = len(list(size_dir.glob("*.png")))
                print(f"   └── {size_dir.name}/ ({count} screenshot)")

    print(f"\n📤 Pronti per upload su App Store Connect!")
    print(f"   cd ios && bundle exec fastlane upload_screenshots")
    print(f"\n🎉 Fatto!")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Operazione interrotta")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Errore: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
