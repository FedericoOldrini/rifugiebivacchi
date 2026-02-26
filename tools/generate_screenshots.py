#!/usr/bin/env python3
"""
Screenshot Generator per App Store - Rifugi e Bivacchi

Automatizza la creazione di screenshot per App Store:
1. Avvia simulatore iOS (o usa quello già attivo)
2. Esegue integration_test per catturare screenshot
3. Aggiunge overlay con titoli e sottotitoli
4. Ridimensiona per tutte le dimensioni App Store richieste

Requisiti:
- Python 3.7+
- Pillow (PIL): pip3 install Pillow
- Xcode e simulatori iOS installati
- Flutter SDK

Uso:
    python3 tools/generate_screenshots.py
    python3 tools/generate_screenshots.py --device "iPhone 15 Pro Max"
    python3 tools/generate_screenshots.py --skip-test  # Solo overlay su screenshot esistenti
    python3 tools/generate_screenshots.py --no-overlay  # Solo cattura, senza overlay
"""

import subprocess
import time
import sys
import argparse
import json
from pathlib import Path
from typing import List, Optional, Tuple

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("❌ Pillow non trovato. Installa con: pip3 install Pillow")
    sys.exit(1)

# Configurazione
PROJECT_ROOT = Path(__file__).parent.parent
RAW_DIR = PROJECT_ROOT / "screenshots" / "raw"
FINAL_DIR = PROJECT_ROOT / "screenshots" / "final"
BUNDLE_ID = "it.federicooldrini.rifugiebivacchi"

# Simulatori iOS supportati per ogni dimensione App Store
SIMULATORS = {
    "iPhone_6_9": "iPhone 17 Pro Max",
    "iPhone_6_7": "iPhone 17 Pro",
    "iPhone_6_5": "iPhone Air",
    "iPad_Pro_13": "iPad Pro 13-inch (M5)",
}

# Device di default per la cattura (poi si ridimensiona per gli altri)
DEFAULT_DEVICE = "iPhone 17 Pro Max"

# Dimensioni App Store richieste
APP_STORE_SIZES = {
    "iPhone_6_9": (1320, 2868),
    "iPhone_6_7": (1290, 2796),
    "iPhone_6_5": (1242, 2688),
    "iPhone_5_5": (1242, 2208),
    "iPad_Pro_13": (2064, 2752),
    "iPad_Pro_12_9": (2048, 2732),
}

# Configurazione screenshot (deve matchare i nomi in integration_test/screenshot_test.dart)
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


def print_step(step: int, total: int, text: str):
    """Stampa step corrente"""
    print(f"\n📍 [{step}/{total}] {text}")


def run_command(
    cmd: List[str], capture_output: bool = True, cwd: Optional[Path] = None
) -> subprocess.CompletedProcess:
    """Esegue comando shell"""
    try:
        result = subprocess.run(
            cmd, capture_output=capture_output, text=True, check=False, cwd=cwd
        )
        return result
    except Exception as e:
        print(f"❌ Errore eseguendo comando: {' '.join(cmd)}")
        print(f"   {e}")
        sys.exit(1)


def get_booted_simulator_udid() -> Optional[str]:
    """Restituisce l'UDID del simulatore già avviato, se presente"""
    result = run_command(["xcrun", "simctl", "list", "devices", "booted", "--json"])
    if result.returncode != 0:
        return None
    try:
        data = json.loads(result.stdout)
        for runtime, devices in data.get("devices", {}).items():
            for device in devices:
                if device.get("state") == "Booted":
                    return device["udid"]
    except (json.JSONDecodeError, KeyError):
        pass
    return None


def find_simulator_udid(device_name: str) -> Optional[str]:
    """Trova l'UDID di un simulatore dato il nome"""
    result = run_command(["xcrun", "simctl", "list", "devices", "--json"])
    if result.returncode != 0:
        return None
    try:
        data = json.loads(result.stdout)
        for runtime, devices in data.get("devices", {}).items():
            for device in devices:
                if device.get("name") == device_name and device.get(
                    "isAvailable", False
                ):
                    return device["udid"]
    except (json.JSONDecodeError, KeyError):
        pass
    return None


def boot_simulator(device_name: str) -> Optional[str]:
    """Avvia simulatore e restituisce UDID"""
    print(f"   Cerco simulatore: {device_name}...")

    udid = find_simulator_udid(device_name)
    if not udid:
        print(f"   ❌ Simulatore '{device_name}' non trovato")
        print(f"   Simulatori disponibili:")
        result = run_command(["xcrun", "simctl", "list", "devices", "available"])
        for line in result.stdout.split("\n"):
            if "iPhone" in line or "iPad" in line:
                print(f"      {line.strip()}")
        return None

    # Verifica se già avviato
    booted = get_booted_simulator_udid()
    if booted == udid:
        print(f"   ✅ Simulatore già avviato (UDID: {udid[:8]}...)")
        return udid

    # Avvia simulatore
    print(f"   Avvio simulatore (UDID: {udid[:8]}...)...")
    run_command(["xcrun", "simctl", "boot", udid])
    run_command(["open", "-a", "Simulator"])
    time.sleep(5)

    print(f"   ✅ Simulatore avviato")
    return udid


def run_integration_test(device_id: str) -> bool:
    """Esegue integration test per catturare screenshot"""
    print(f"   Esecuzione integration_test su device {device_id[:8]}...")
    print(f"   (il primo build può richiedere qualche minuto)")

    # Usa flutter drive con driver che salva gli screenshot su disco
    result = run_command(
        [
            "flutter",
            "drive",
            "--driver=test_driver/integration_driver.dart",
            "--target=integration_test/screenshot_test.dart",
            "-d",
            device_id,
            "--no-pub",
        ],
        capture_output=False,
        cwd=PROJECT_ROOT,
    )

    if result.returncode != 0:
        print(f"   ❌ Integration test fallito (exit code: {result.returncode})")
        return False

    print(f"   ✅ Integration test completato")
    return True


def find_raw_screenshots() -> List[Path]:
    """Trova gli screenshot raw catturati dal test"""
    # Integration test li salva nella directory del progetto o in una directory specifica
    # Controlliamo diverse posizioni possibili
    search_dirs = [
        RAW_DIR,
        PROJECT_ROOT / "build" / "screenshots",
        PROJECT_ROOT,
    ]

    screenshots = []
    for search_dir in search_dirs:
        if search_dir.exists():
            for png in search_dir.glob("*.png"):
                # Matcha solo i nomi degli screenshot attesi
                for key in SCREENSHOTS_CONFIG:
                    if key in png.stem:
                        screenshots.append(png)
                        break

    return sorted(set(screenshots))


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


def process_overlays(resize: bool = True) -> int:
    """Applica overlay a tutti gli screenshot raw e opzionalmente ridimensiona"""
    screenshots = list(RAW_DIR.glob("*.png")) if RAW_DIR.exists() else []

    if not screenshots:
        print(f"   ❌ Nessun screenshot trovato in {RAW_DIR}")
        return 0

    print(f"   Trovati {len(screenshots)} screenshot")
    processed = 0

    for screenshot_path in sorted(screenshots):
        # Trova configurazione
        config = None
        for key, cfg in SCREENSHOTS_CONFIG.items():
            if key in screenshot_path.stem:
                config = cfg
                config_key = key
                break

        if not config:
            print(f"   ⚠️  Config non trovata per: {screenshot_path.name}")
            continue

        if resize:
            # Genera versione per ogni dimensione App Store
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
            # Mantieni dimensione originale
            output_path = FINAL_DIR / screenshot_path.name
            if add_overlay(
                screenshot_path, output_path, config["title"], config["subtitle"]
            ):
                print(f"   ✅ {screenshot_path.name}")
                processed += 1

    return processed


def main():
    parser = argparse.ArgumentParser(
        description="Genera screenshot per App Store - Rifugi e Bivacchi"
    )
    parser.add_argument(
        "--device",
        type=str,
        default=DEFAULT_DEVICE,
        help=f"Nome simulatore iOS (default: {DEFAULT_DEVICE})",
    )
    parser.add_argument(
        "--skip-test",
        action="store_true",
        help="Salta integration test, usa screenshot raw esistenti",
    )
    parser.add_argument(
        "--no-overlay",
        action="store_true",
        help="Solo cattura screenshot, senza overlay",
    )
    parser.add_argument(
        "--no-resize",
        action="store_true",
        help="Non ridimensionare per tutte le dimensioni App Store",
    )
    args = parser.parse_args()

    print_header("Screenshot Generator - Rifugi e Bivacchi")

    total_steps = 3
    if args.skip_test:
        total_steps = 1
    elif args.no_overlay:
        total_steps = 2

    # Step 1: Avvia simulatore e esegui test
    if not args.skip_test:
        print_step(1, total_steps, "Avvio simulatore e cattura screenshot")

        device_id = boot_simulator(args.device)
        if not device_id:
            sys.exit(1)

        # Assicura che la directory raw esista
        RAW_DIR.mkdir(parents=True, exist_ok=True)

        # Esegui integration test
        if not run_integration_test(device_id):
            print("\n❌ Cattura screenshot fallita")
            print("   Verifica che integration_test/screenshot_test.dart esista")
            print("   e che il progetto Flutter compili senza errori")
            sys.exit(1)

        # Cerca e sposta screenshot nella directory raw se necessario
        found = find_raw_screenshots()
        print(f"   Trovati {len(found)} screenshot raw")

        # Sposta nella directory raw se non ci sono già
        for src in found:
            if src.parent != RAW_DIR:
                dest = RAW_DIR / src.name
                src.rename(dest)
                print(f"   📁 Spostato: {src.name} → screenshots/raw/")

    # Step 2: Applica overlay
    if not args.no_overlay:
        step = 2 if not args.skip_test else 1
        print_step(step, total_steps, "Applicazione overlay e ridimensionamento")

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
        raw_count = len(list(RAW_DIR.glob("*.png")))
        print(f"📁 Screenshot raw:   {RAW_DIR} ({raw_count} file)")

    if FINAL_DIR.exists():
        final_count = len(list(FINAL_DIR.rglob("*.png")))
        print(f"📁 Screenshot finali: {FINAL_DIR} ({final_count} file)")

        # Mostra struttura directory
        for size_dir in sorted(FINAL_DIR.iterdir()):
            if size_dir.is_dir():
                count = len(list(size_dir.glob("*.png")))
                print(f"   └── {size_dir.name}/ ({count} screenshot)")

    print(f"\n📤 Pronti per upload su App Store Connect!")
    print(f"   Usa: python3 tools/upload_screenshots.py")
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
