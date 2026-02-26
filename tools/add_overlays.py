#!/usr/bin/env python3
"""
Add Overlays to Screenshots

Aggiunge titoli e sottotitoli agli screenshot catturati.
Può essere usato sia con screenshot manuali che con quelli da Flutter Driver.

Uso:
    python3 tools/add_overlays.py
    python3 tools/add_overlays.py --input test_driver/screenshots/ --output screenshots/final/
"""

import sys
import argparse
from pathlib import Path
from typing import List, Optional, Tuple

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("❌ Pillow non trovato. Installa con: pip3 install Pillow")
    sys.exit(1)

# Configurazione screenshot
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
TEXT_COLOR = (255, 255, 255)  # Bianco
SUBTITLE_COLOR = (200, 230, 228)  # Bianco-teal chiaro

# Dimensioni App Store richieste
APP_STORE_SIZES = {
    "iPhone_6_9": (1320, 2868),
    "iPhone_6_7": (1290, 2796),
    "iPhone_6_5": (1242, 2688),
    "iPhone_5_5": (1242, 2208),
    "iPad_Pro_13": (2064, 2752),
    "iPad_Pro_12_9": (2048, 2732),
}


def add_overlay(
    input_path: Path,
    output_path: Path,
    title: str,
    subtitle: str,
    target_size: Optional[Tuple[int, int]] = None,
) -> bool:
    """Aggiunge overlay con titolo e sottotitolo"""
    try:
        # Apri immagine
        img = Image.open(input_path)

        # Ridimensiona se richiesto
        if target_size:
            img = img.resize(target_size, Image.Resampling.LANCZOS)

        width, height = img.size

        # Crea layer overlay
        overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)

        # Calcola dimensioni font
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
            title_font_bold = ImageFont.truetype(
                "/System/Library/Fonts/Helvetica.ttc", title_font_size
            )
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            title_font_bold = title_font

        # Calcola posizioni
        padding = int(width * 0.05)
        top_margin = int(height * 0.06)

        # Dimensioni testi
        title_bbox = draw.textbbox((0, 0), title, font=title_font_bold)
        title_width = title_bbox[2] - title_bbox[0]
        title_height = title_bbox[3] - title_bbox[1]

        subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
        subtitle_height = subtitle_bbox[3] - subtitle_bbox[1]

        # Disegna rettangolo sfondo (completamente opaco per coprire l'app sotto)
        bg_height = title_height + subtitle_height + padding * 2
        draw.rectangle([(0, 0), (width, bg_height + top_margin)], fill=(*BG_COLOR, 255))

        # Disegna titolo
        title_x = (width - title_width) // 2
        title_y = top_margin
        draw.text((title_x, title_y), title, font=title_font_bold, fill=TEXT_COLOR)

        # Disegna sottotitolo
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
        print(f"❌ Errore: {e}")
        return False


def process_screenshots(input_dir: Path, output_dir: Path, resize: bool = False):
    """Processa tutti gli screenshot in una directory"""

    if not input_dir.exists():
        print(f"❌ Directory non trovata: {input_dir}")
        return

    screenshots = list(input_dir.glob("*.png"))

    if not screenshots:
        print(f"⚠️  Nessun screenshot trovato in: {input_dir}")
        return

    print(f"\n🎨 Trovati {len(screenshots)} screenshot da processare")
    print(f"📁 Input:  {input_dir}")
    print(f"📁 Output: {output_dir}\n")

    processed = 0

    for screenshot_path in sorted(screenshots):
        # Trova configurazione per questo screenshot
        config = None
        for key, cfg in SCREENSHOTS_CONFIG.items():
            if key in screenshot_path.stem:
                config = cfg
                break

        if not config:
            print(f"⚠️  Configurazione non trovata per: {screenshot_path.name}")
            continue

        print(f"🖼️  Processando: {screenshot_path.name}")
        print(f"   Titolo: {config['title']}")

        # Se resize richiesto, crea versioni per ogni dimensione
        if resize:
            for size_name, size_dims in APP_STORE_SIZES.items():
                output_path = output_dir / size_name / screenshot_path.name

                if add_overlay(
                    screenshot_path,
                    output_path,
                    config["title"],
                    config["subtitle"],
                    target_size=size_dims,
                ):
                    print(f"   ✅ {size_name}: {output_path.name}")
                    processed += 1
        else:
            # Mantieni dimensione originale
            output_path = output_dir / screenshot_path.name

            if add_overlay(
                screenshot_path, output_path, config["title"], config["subtitle"]
            ):
                print(f"   ✅ Salvato: {output_path.name}")
                processed += 1

    print(f"\n✅ Completato! {processed} screenshot processati")
    print(f"📁 Screenshot finali in: {output_dir}")


def main():
    parser = argparse.ArgumentParser(
        description="Aggiunge overlay agli screenshot per App Store"
    )
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("screenshots/raw"),
        help="Directory input con screenshot (default: screenshots/raw)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("screenshots/final"),
        help="Directory output (default: screenshots/final)",
    )
    parser.add_argument(
        "--resize",
        action="store_true",
        help="Ridimensiona per tutte le dimensioni App Store richieste",
    )

    args = parser.parse_args()

    print("=" * 70)
    print("🏔️  Screenshot Overlay Tool - Rifugi e Bivacchi")
    print("=" * 70)

    process_screenshots(args.input, args.output, args.resize)

    print("\n🎉 Fatto! Gli screenshot sono pronti per App Store Connect")


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
