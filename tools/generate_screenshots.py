#!/usr/bin/env python3
"""
Screenshot Generator per App Store - Rifugi e Bivacchi

Questo script automatizza la creazione di screenshot per App Store:
1. Avvia l'app su vari simulatori iOS
2. Cattura screenshot delle schermate principali
3. Aggiunge overlay con titoli e sottotitoli
4. Genera screenshot per tutte le dimensioni richieste

Requisiti:
- Python 3.7+
- Pillow (PIL): pip3 install Pillow
- Xcode e simulatori iOS installati
- App già buildato per simulatore

Uso:
    python3 tools/generate_screenshots.py
    
Con opzioni:
    python3 tools/generate_screenshots.py --device "iPhone 15 Pro Max" --output screenshots/
"""

import subprocess
import time
import os
import sys
from pathlib import Path
from typing import List, Tuple, Dict

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("❌ Pillow non trovato. Installa con: pip3 install Pillow")
    sys.exit(1)

# Configurazione
PROJECT_ROOT = Path(__file__).parent.parent
OUTPUT_DIR = PROJECT_ROOT / "screenshots"
BUNDLE_ID = "com.tuonome.rifugibivacchi"  # TODO: Aggiorna con il tuo Bundle ID

# Dimensioni richieste da App Store
SCREENSHOT_SIZES = {
    "iPhone 6.7": (1290, 2796),  # iPhone 14 Pro Max, 15 Pro Max
    "iPhone 6.5": (1242, 2688),  # iPhone 11 Pro Max, XS Max
    "iPhone 5.5": (1242, 2208),  # iPhone 8 Plus
    "iPad Pro 12.9": (2048, 2732),  # iPad Pro 12.9"
}

# Simulatori da usare per ogni dimensione
SIMULATORS = {
    "iPhone 6.7": "iPhone 15 Pro Max",
    "iPhone 6.5": "iPhone 11 Pro Max",
    "iPhone 5.5": "iPhone 8 Plus",
    "iPad Pro 12.9": "iPad Pro (12.9-inch) (6th generation)",
}

# Configurazione screenshot
SCREENSHOTS_CONFIG = [
    {
        "name": "01_lista_rifugi",
        "title": "Scopri oltre 1000 rifugi",
        "subtitle": "Database completo CAI con informazioni dettagliate",
        "wait_time": 3,
        "instructions": "Naviga alla schermata Home con lista rifugi"
    },
    {
        "name": "02_mappa",
        "title": "Mappa intelligente",
        "subtitle": "Trova i rifugi più vicini con clustering avanzato",
        "wait_time": 2,
        "instructions": "Vai al tab Mappa"
    },
    {
        "name": "03_dettaglio",
        "title": "Tutte le info che cerchi",
        "subtitle": "Contatti, servizi, altitudine e foto",
        "wait_time": 2,
        "instructions": "Apri dettaglio rifugio"
    },
    {
        "name": "04_ricerca",
        "title": "Ricerca avanzata",
        "subtitle": "Filtra per altitudine, servizi e disponibilità",
        "wait_time": 2,
        "instructions": "Apri filtri ricerca"
    },
    {
        "name": "05_passaporto",
        "title": "Passaporto dei Rifugi",
        "subtitle": "Registra le tue visite e colleziona i timbri",
        "wait_time": 2,
        "instructions": "Vai alla schermata Passaporto"
    },
]

# Colori tema app
BG_COLOR = (46, 125, 50)  # Verde montagna
TEXT_COLOR = (255, 255, 255)  # Bianco
SUBTITLE_COLOR = (220, 240, 220)  # Bianco ghiaccio


def print_header(text: str):
    """Stampa intestazione colorata"""
    print(f"\n{'=' * 70}")
    print(f"🏔️  {text}")
    print(f"{'=' * 70}\n")


def print_step(step: int, total: int, text: str):
    """Stampa step corrente"""
    print(f"📍 [{step}/{total}] {text}")


def run_command(cmd: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
    """Esegue comando shell"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=capture_output,
            text=True,
            check=False
        )
        return result
    except Exception as e:
        print(f"❌ Errore eseguendo comando: {' '.join(cmd)}")
        print(f"   {e}")
        sys.exit(1)


def get_available_simulators() -> List[str]:
    """Ottiene lista simulatori iOS disponibili"""
    result = run_command(["xcrun", "simctl", "list", "devices", "available"])
    simulators = []
    
    for line in result.stdout.split('\n'):
        if 'iPhone' in line or 'iPad' in line:
            # Estrae nome simulatore
            parts = line.split('(')
            if len(parts) >= 2:
                name = parts[0].strip()
                if name and not name.startswith('--'):
                    simulators.append(name)
    
    return simulators


def boot_simulator(device_name: str) -> bool:
    """Avvia simulatore iOS"""
    print(f"   Avvio simulatore: {device_name}...")
    
    # Chiudi tutti i simulatori aperti
    run_command(["killall", "Simulator"], capture_output=True)
    time.sleep(2)
    
    # Avvia simulatore
    result = run_command([
        "xcrun", "simctl", "boot", device_name
    ])
    
    if result.returncode != 0 and "Unable to boot device in current state: Booted" not in result.stderr:
        print(f"   ⚠️  Simulatore già avviato o errore")
    
    # Apri app Simulator
    run_command(["open", "-a", "Simulator"])
    time.sleep(3)
    
    return True


def install_and_launch_app(device_name: str) -> bool:
    """Installa e avvia l'app sul simulatore"""
    print(f"   Installazione e avvio app su {device_name}...")
    
    # Trova il bundle dell'app
    app_path = PROJECT_ROOT / "build" / "ios" / "iphonesimulator" / "Runner.app"
    
    if not app_path.exists():
        print(f"   ⚠️  App non trovata in {app_path}")
        print(f"   Esegui prima: flutter build ios --simulator")
        return False
    
    # Installa app
    result = run_command([
        "xcrun", "simctl", "install",
        device_name,
        str(app_path)
    ])
    
    if result.returncode != 0:
        print(f"   ❌ Errore installazione app: {result.stderr}")
        return False
    
    time.sleep(1)
    
    # Avvia app
    result = run_command([
        "xcrun", "simctl", "launch",
        device_name,
        BUNDLE_ID
    ])
    
    if result.returncode != 0:
        print(f"   ❌ Errore avvio app: {result.stderr}")
        return False
    
    time.sleep(2)
    return True


def capture_screenshot(device_name: str, output_path: Path) -> bool:
    """Cattura screenshot dal simulatore"""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    result = run_command([
        "xcrun", "simctl", "io",
        device_name,
        "screenshot",
        str(output_path)
    ])
    
    if result.returncode != 0:
        print(f"   ❌ Errore cattura screenshot: {result.stderr}")
        return False
    
    return output_path.exists()


def add_overlay_to_screenshot(
    input_path: Path,
    output_path: Path,
    title: str,
    subtitle: str
) -> bool:
    """Aggiunge overlay con titolo e sottotitolo allo screenshot"""
    try:
        # Apri immagine
        img = Image.open(input_path)
        width, height = img.size
        
        # Crea layer per overlay
        overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Calcola dimensioni font basate su dimensione immagine
        title_font_size = int(width * 0.045)  # ~4.5% della larghezza
        subtitle_font_size = int(width * 0.028)  # ~2.8% della larghezza
        
        # Carica font (usa system font se disponibile)
        try:
            title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", title_font_size)
            subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", subtitle_font_size)
        except:
            # Fallback a font default
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
        
        # Calcola posizioni testi (in alto)
        padding = int(width * 0.05)
        top_margin = int(height * 0.08)
        
        # Calcola dimensioni testi
        title_bbox = draw.textbbox((0, 0), title, font=title_font)
        title_width = title_bbox[2] - title_bbox[0]
        title_height = title_bbox[3] - title_bbox[1]
        
        subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
        subtitle_height = subtitle_bbox[3] - subtitle_bbox[1]
        
        # Disegna rettangolo sfondo per titolo
        bg_height = title_height + subtitle_height + padding * 2
        draw.rectangle(
            [(0, 0), (width, bg_height + top_margin)],
            fill=(*BG_COLOR, 230)  # Verde con alpha
        )
        
        # Disegna titolo (centrato)
        title_x = (width - title_width) // 2
        title_y = top_margin
        draw.text((title_x, title_y), title, font=title_font, fill=TEXT_COLOR)
        
        # Disegna sottotitolo (centrato)
        subtitle_x = (width - subtitle_width) // 2
        subtitle_y = title_y + title_height + int(padding * 0.5)
        draw.text((subtitle_x, subtitle_y), subtitle, font=subtitle_font, fill=SUBTITLE_COLOR)
        
        # Combina overlay con immagine originale
        img = img.convert('RGBA')
        combined = Image.alpha_composite(img, overlay)
        combined = combined.convert('RGB')
        
        # Salva
        output_path.parent.mkdir(parents=True, exist_ok=True)
        combined.save(output_path, 'PNG', quality=95)
        
        return True
        
    except Exception as e:
        print(f"   ❌ Errore aggiunta overlay: {e}")
        return False


def resize_screenshot(input_path: Path, output_path: Path, size: Tuple[int, int]) -> bool:
    """Ridimensiona screenshot alla dimensione richiesta"""
    try:
        img = Image.open(input_path)
        
        # Ridimensiona mantenendo proporzioni
        img_resized = img.resize(size, Image.Resampling.LANCZOS)
        
        # Salva
        output_path.parent.mkdir(parents=True, exist_ok=True)
        img_resized.save(output_path, 'PNG', quality=95)
        
        return True
        
    except Exception as e:
        print(f"   ❌ Errore ridimensionamento: {e}")
        return False


def generate_screenshots_for_device(device_size: str, device_name: str) -> bool:
    """Genera tutti gli screenshot per un dispositivo specifico"""
    print_step(1, 4, f"Preparazione {device_size} ({device_name})")
    
    # Avvia simulatore
    if not boot_simulator(device_name):
        return False
    
    # Installa e avvia app
    if not install_and_launch_app(device_name):
        print(f"   ⚠️  Assicurati che l'app sia compilata con:")
        print(f"      flutter build ios --simulator")
        return False
    
    print_step(2, 4, "Cattura screenshot")
    
    # Directory per screenshot raw
    raw_dir = OUTPUT_DIR / "raw" / device_size.replace(" ", "_").replace(".", "_")
    raw_dir.mkdir(parents=True, exist_ok=True)
    
    # Cattura ogni screenshot
    for i, config in enumerate(SCREENSHOTS_CONFIG, 1):
        print(f"   📸 [{i}/{len(SCREENSHOTS_CONFIG)}] {config['name']}...")
        print(f"      ℹ️  {config['instructions']}")
        
        # Aspetta che l'utente navighi alla schermata corretta
        input(f"      ⏸️  Premi INVIO quando sei pronto per lo screenshot...")
        
        time.sleep(config['wait_time'])
        
        # Cattura screenshot
        raw_path = raw_dir / f"{config['name']}_raw.png"
        if capture_screenshot(device_name, raw_path):
            print(f"      ✅ Screenshot salvato: {raw_path.name}")
        else:
            print(f"      ❌ Errore cattura screenshot")
            continue
    
    print_step(3, 4, "Aggiunta overlay")
    
    # Directory per screenshot con overlay
    overlay_dir = OUTPUT_DIR / "with_overlay" / device_size.replace(" ", "_").replace(".", "_")
    overlay_dir.mkdir(parents=True, exist_ok=True)
    
    # Aggiungi overlay a ogni screenshot
    for i, config in enumerate(SCREENSHOTS_CONFIG, 1):
        raw_path = raw_dir / f"{config['name']}_raw.png"
        overlay_path = overlay_dir / f"{config['name']}.png"
        
        if raw_path.exists():
            print(f"   🎨 [{i}/{len(SCREENSHOTS_CONFIG)}] Aggiungo overlay a {config['name']}...")
            if add_overlay_to_screenshot(
                raw_path,
                overlay_path,
                config['title'],
                config['subtitle']
            ):
                print(f"      ✅ Overlay aggiunto: {overlay_path.name}")
            else:
                print(f"      ❌ Errore aggiunta overlay")
    
    print_step(4, 4, "Ridimensionamento per App Store")
    
    # Ridimensiona per dimensione target
    target_size = SCREENSHOT_SIZES[device_size]
    final_dir = OUTPUT_DIR / "final" / device_size.replace(" ", "_").replace(".", "_")
    final_dir.mkdir(parents=True, exist_ok=True)
    
    for i, config in enumerate(SCREENSHOTS_CONFIG, 1):
        overlay_path = overlay_dir / f"{config['name']}.png"
        final_path = final_dir / f"{i}_{config['name']}.png"
        
        if overlay_path.exists():
            print(f"   📐 [{i}/{len(SCREENSHOTS_CONFIG)}] Ridimensiono {config['name']}...")
            if resize_screenshot(overlay_path, final_path, target_size):
                print(f"      ✅ Screenshot finale: {final_path.name}")
            else:
                print(f"      ❌ Errore ridimensionamento")
    
    print(f"\n✅ Screenshot completati per {device_size}!")
    print(f"   📁 Cartella: {final_dir}")
    
    return True


def main():
    """Funzione principale"""
    print_header("Screenshot Generator per App Store - Rifugi e Bivacchi")
    
    # Verifica requisiti
    print("🔍 Verifica requisiti...")
    
    # Verifica Xcode
    result = run_command(["xcode-select", "-p"])
    if result.returncode != 0:
        print("❌ Xcode non trovato. Installa Xcode da App Store.")
        sys.exit(1)
    print("   ✅ Xcode trovato")
    
    # Verifica simulatori
    available_sims = get_available_simulators()
    if not available_sims:
        print("❌ Nessun simulatore iOS trovato")
        sys.exit(1)
    print(f"   ✅ {len(available_sims)} simulatori disponibili")
    
    # Verifica build app
    app_path = PROJECT_ROOT / "build" / "ios" / "iphonesimulator" / "Runner.app"
    if not app_path.exists():
        print("\n⚠️  App non compilata per simulatore")
        print("   Esegui: flutter build ios --simulator")
        response = input("\n   Vuoi compilare ora? (s/n): ")
        if response.lower() == 's':
            print("\n📦 Compilazione app...")
            result = run_command(
                ["flutter", "build", "ios", "--simulator"],
                capture_output=False
            )
            if result.returncode != 0:
                print("❌ Errore compilazione")
                sys.exit(1)
        else:
            sys.exit(1)
    
    print("\n✅ Tutti i requisiti soddisfatti!")
    
    # Mostra dispositivi supportati
    print("\n📱 Dispositivi supportati:")
    for device_size, device_name in SIMULATORS.items():
        print(f"   • {device_size}: {device_name}")
    
    # Chiedi conferma
    print(f"\n📸 Verranno generati {len(SCREENSHOTS_CONFIG)} screenshot per ogni dispositivo")
    response = input("\n   Vuoi procedere? (s/n): ")
    
    if response.lower() != 's':
        print("❌ Operazione annullata")
        sys.exit(0)
    
    # Genera screenshot per ogni dispositivo
    success_count = 0
    for device_size, device_name in SIMULATORS.items():
        print(f"\n{'=' * 70}")
        print(f"📱 Generazione screenshot per {device_size}")
        print(f"{'=' * 70}")
        
        if generate_screenshots_for_device(device_size, device_name):
            success_count += 1
        
        # Chiedi se continuare con prossimo dispositivo
        if device_size != list(SIMULATORS.keys())[-1]:
            response = input(f"\n   Continuare con il prossimo dispositivo? (s/n): ")
            if response.lower() != 's':
                break
    
    # Riepilogo finale
    print_header("Generazione Screenshot Completata!")
    print(f"✅ Screenshot generati per {success_count}/{len(SIMULATORS)} dispositivi")
    print(f"📁 Cartella output: {OUTPUT_DIR / 'final'}")
    print(f"\n📤 Carica gli screenshot in App Store Connect da:")
    print(f"   {OUTPUT_DIR / 'final'}")
    print("\n🎉 Fatto! Buona pubblicazione su App Store!")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Operazione interrotta dall'utente")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Errore inaspettato: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
