#!/usr/bin/env python3
"""
Screenshot Overlay & Resize — Rifugi e Bivacchi

Applica overlay (titolo + sottotitolo) agli screenshot raw generati dai golden tests
e ridimensiona alle dimensioni esatte richieste dall'App Store.

Questo script viene invocato da Fastlane con:
    python3 tools/generate_screenshots.py --skip-test

I raw screenshot devono già essere presenti in screenshots/raw/<device_name>/.
Vengono generati dai golden tests (test/screenshots/screenshot_golden_test.dart)
e organizzati dal Fastfile (helper organize_golden_screenshots).

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
    from PIL import Image, ImageDraw, ImageFont
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
# Queste dimensioni NON hanno un golden test dedicato, quindi vengono ricavate
# ridimensionando lo screenshot del device nativo più simile
LEGACY_SIZE_SOURCE = {
    "iPhone_5_5": "iPhone_6_5",  # iPhone 5.5" ← resize da iPhone 6.5"
    "iPad_Pro_12_9": "iPad_Pro_13",  # iPad Pro 12.9" ← resize da iPad Pro 13"
}

# Configurazione screenshot (deve matchare i nomi nel golden test)
SCREENSHOTS_CONFIG = {
    "01_lista_rifugi": {
        "title": "Scopri oltre 1000 rifugi",
        "subtitle": "Database completo CAI con informazioni dettagliate",
    },
    "02_mappa": {
        "title": "Mappa intelligente",
        "subtitle": "Trova i rifugi più vicini con clustering avanzato",
    },
    "03_dettaglio_rifugio": {
        "title": "Tutte le info che cerchi",
        "subtitle": "Contatti, servizi, altitudine e foto",
    },
    "04_profilo": {
        "title": "Il tuo profilo alpinista",
        "subtitle": "Tieni traccia dei rifugi visitati e preferiti",
    },
    "05_passaporto": {
        "title": "Passaporto dei Rifugi",
        "subtitle": "Registra le tue visite e colleziona i timbri",
    },
}

# Colori tema (deepTeal = #2C5F5D = RGB 44, 95, 93)
BG_COLOR = (44, 95, 93)
TEXT_COLOR = (255, 255, 255)
SUBTITLE_COLOR = (200, 230, 228)


def print_header(text: str):
    """Stampa intestazione"""
    print(f"\n{'=' * 70}")
    print(f"🏔️  {text}")
    print(f"{'=' * 70}\n")


def add_overlay(
    input_path: Path,
    output_path: Path,
    title: str,
    subtitle: str,
    target_size: Optional[Tuple[int, int]] = None,
) -> bool:
    """Aggiunge overlay con titolo e sottotitolo"""
    try:
        img = Image.open(input_path)

        # Ridimensiona se richiesto
        if target_size:
            img = img.resize(target_size, Image.Resampling.LANCZOS)

        width, height = img.size

        # Crea layer overlay
        overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)

        # Dimensioni font proporzionali
        title_font_size = int(width * 0.048)
        subtitle_font_size = int(width * 0.030)

        # Carica font
        try:
            title_font = ImageFont.truetype(
                "/System/Library/Fonts/Helvetica.ttc", title_font_size
            )
            subtitle_font = ImageFont.truetype(
                "/System/Library/Fonts/Helvetica.ttc", subtitle_font_size
            )
        except Exception:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()

        # Calcola posizioni
        padding = int(width * 0.05)
        top_margin = int(height * 0.06)

        # Dimensioni testi
        title_bbox = draw.textbbox((0, 0), title, font=title_font)
        title_width = title_bbox[2] - title_bbox[0]
        title_height = title_bbox[3] - title_bbox[1]

        subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
        subtitle_height = subtitle_bbox[3] - subtitle_bbox[1]

        # Rettangolo sfondo
        bg_height = title_height + subtitle_height + padding * 2
        draw.rectangle([(0, 0), (width, bg_height + top_margin)], fill=(*BG_COLOR, 255))

        # Titolo centrato
        title_x = (width - title_width) // 2
        title_y = top_margin
        draw.text((title_x, title_y), title, font=title_font, fill=TEXT_COLOR)

        # Sottotitolo centrato
        subtitle_x = (width - subtitle_width) // 2
        subtitle_y = title_y + title_height + int(padding * 0.6)
        draw.text(
            (subtitle_x, subtitle_y), subtitle, font=subtitle_font, fill=SUBTITLE_COLOR
        )

        # Combina
        img = img.convert("RGBA")
        combined = Image.alpha_composite(img, overlay)
        combined = combined.convert("RGB")

        # Salva
        output_path.parent.mkdir(parents=True, exist_ok=True)
        combined.save(output_path, "PNG", quality=95, optimize=True)

        return True

    except Exception as e:
        print(f"   ❌ Errore overlay: {e}")
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
    """Applica overlay usando screenshot raw per-device.

    Per le dimensioni native (che hanno un golden test dedicato):
      Usa i raw dal device corrispondente → overlay + resize alla dimensione esatta
    Per le dimensioni legacy (senza golden test dedicato):
      Usa i raw dal device source più simile → overlay + resize
    """
    processed = 0

    for size_name, target_dims in APP_STORE_SIZES.items():
        # Determina la directory sorgente per questa dimensione
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
        print("❌ La cattura automatica via simulatore è stata rimossa.")
        print("   Usa i golden tests tramite Fastlane:")
        print("   cd ios && bundle exec fastlane screenshots")
        print()
        print("   Oppure usa --skip-test per applicare overlay a raw esistenti.")
        sys.exit(1)

    # Verifica che ci siano raw screenshot
    if not RAW_DIR.exists():
        print(f"❌ Directory raw non trovata: {RAW_DIR}")
        print(f"   Esegui prima i golden tests tramite Fastlane:")
        print(f"   cd ios && bundle exec fastlane screenshots")
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
