#!/usr/bin/env python3
"""
Script per rimuovere i duplicati dal file app_data.json basandosi sull'osmId.
"""

import json
import sys
from pathlib import Path


def remove_duplicates(input_file='app_data.json', output_file=None):
    """
    Rimuove i duplicati dal file JSON basandosi sull'osmId.
    
    Args:
        input_file: Il file JSON di input (default: app_data.json)
        output_file: Il file JSON di output (default: sovrascrive l'input)
    """
    # Se non è specificato un file di output, usa lo stesso file di input
    if output_file is None:
        output_file = input_file
    
    input_path = Path(input_file)
    
    # Verifica che il file esista
    if not input_path.exists():
        print(f"❌ Errore: Il file {input_file} non esiste!")
        sys.exit(1)
    
    # Leggi il file JSON
    print(f"📖 Lettura del file {input_file}...")
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Errore nel parsing del JSON: {e}")
        sys.exit(1)
    
    print(f"✓ Totale rifugi originali: {len(data)}")
    
    # Rimuovi duplicati basandoti sull'osmId
    seen_ids = set()
    unique_data = []
    duplicate_ids = []
    
    for item in data:
        osm_id = item.get('osmId')
        if osm_id:
            if osm_id not in seen_ids:
                seen_ids.add(osm_id)
                unique_data.append(item)
            else:
                duplicate_ids.append((osm_id, item.get('name', 'N/A')))
        else:
            # Mantieni gli elementi senza osmId
            unique_data.append(item)
            print(f"⚠️  Elemento senza osmId: {item.get('name', 'N/A')}")
    
    print(f"✓ Rifugi unici: {len(unique_data)}")
    print(f"✓ Duplicati rimossi: {len(data) - len(unique_data)}")
    
    # Mostra alcuni duplicati rimossi
    if duplicate_ids:
        print(f"\n📋 Primi 10 duplicati rimossi (osmId - nome):")
        for osm_id, name in duplicate_ids[:10]:
            print(f"   • {osm_id}: {name}")
    
    # Salva il file senza duplicati
    output_path = Path(output_file)
    print(f"\n💾 Salvataggio in {output_file}...")
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(unique_data, f, ensure_ascii=False, indent=4)
        print(f"✅ File salvato con successo!")
        print(f"   Dimensione: {output_path.stat().st_size:,} bytes")
    except Exception as e:
        print(f"❌ Errore nel salvataggio del file: {e}")
        sys.exit(1)


def main():
    """Funzione principale."""
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else None
    else:
        input_file = 'app_data.json'
        output_file = None
    
    print("🧹 Script di rimozione duplicati")
    print("=" * 50)
    remove_duplicates(input_file, output_file)
    print("=" * 50)
    print("✨ Completato!")


if __name__ == '__main__':
    main()
