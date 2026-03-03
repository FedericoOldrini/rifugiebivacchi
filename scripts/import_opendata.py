#!/usr/bin/env python3
"""
Import dati Open Data regionali per enrichment dei rifugi esistenti.

Fonti supportate:
1. Provincia Autonoma di Bolzano — CSV elenco rifugi alpini
   URL: https://data.civis.bz.it/...elencorifugi-alpini.csv
   Dati: nome IT/DE, altitudine, comune, proprietario, telefono, email, website
   Limiti: NESSUNA coordinata GPS — utilizzabile solo per enrichment (match per nome)

Questo script NON produce shelter standalone, ma produce un file di enrichment
che il merge_sources.py usa per arricchire i record gia' geolocati da altre fonti
(CAI, OSM, Wikidata) con dati di contatto (telefono, email, website) e proprieta'.

Output: scripts/data/opendata_enrichment.json (formato speciale per enrichment)

Licenza: CC BY (Provincia Autonoma di Bolzano)
"""

import csv
import io
import json
import re
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path
from typing import Optional

sys.path.insert(0, str(Path(__file__).parent))

from shared import (
    UnifiedShelter,
    normalize_name,
    levenshtein_similarity,
    save_intermediate,
    print_stats,
    DATA_DIR,
)

# ── Configurazione ──────────────────────────────────────────────────

# Provincia Autonoma di Bolzano — elenco rifugi alpini
SOUTH_TYROL_CSV_URL = (
    "https://data.civis.bz.it/dataset/"
    "e8725c8a-8865-4784-ac9c-b1568a1f3842/resource/"
    "807ab68b-531e-4188-ae77-6c6b34bd0b87/download/"
    "elencorifugi-alpini.csv"
)

OUTPUT_FILE = "opendata_enrichment.json"

USER_AGENT = "RifugiBivacchiBot/1.0 (https://rifugibivacchi.app)"

MAX_RETRIES = 3
RETRY_DELAY_S = 10

# Soglia similarita' nome per match enrichment (piu' bassa del dedup cross-source
# perche' i nomi sono gia' controllati manualmente — CSV ufficiale provinciale)
ENRICHMENT_NAME_THRESHOLD = 0.75


# ── Fetch CSV ───────────────────────────────────────────────────────


def fetch_csv(url):
    """
    Scarica un CSV da URL e restituisce il contenuto come stringa.
    """
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            print(f"  Fetch CSV: tentativo {attempt}/{MAX_RETRIES}...")
            req = urllib.request.Request(
                url,
                headers={"User-Agent": USER_AGENT},
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                raw = resp.read()
                # Prova UTF-8, poi latin-1 come fallback
                try:
                    return raw.decode("utf-8")
                except UnicodeDecodeError:
                    return raw.decode("latin-1")

        except urllib.error.HTTPError as e:
            if e.code in (429, 503, 504):
                wait = RETRY_DELAY_S * attempt
                print(f"    HTTP {e.code} — attendo {wait}s...")
                time.sleep(wait)
            else:
                print(f"    ERRORE HTTP {e.code}: {e.reason}")
                raise
        except urllib.error.URLError as e:
            print(f"    ERRORE connessione: {e.reason}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY_S)
            else:
                raise

    print("  ERRORE: tutti i tentativi di fetch falliti")
    sys.exit(1)


# ── Parsing CSV Alto Adige ──────────────────────────────────────────


def parse_south_tyrol_csv(csv_content):
    """
    Parsa il CSV dell'Alto Adige (delimitatore punto e virgola).

    Colonne attese:
    - Nome italiano del rifugio
    - Nome tedesco del rifugio
    - Altitudine (m)
    - Comune
    - Proprietà (CAI/AVS/Provincia/Privato)
    - Telefono
    - Email
    - Internet (URL)

    Il CSV ha righe di intestazione per gruppi montuosi (es. "Sesvenna",
    "Alpi Aurine") che non sono record validi.
    """
    records = []
    current_mountain_group = None

    reader = csv.reader(io.StringIO(csv_content), delimiter=";")

    for row in reader:
        # Salta righe vuote
        if not row or all(not cell.strip() for cell in row):
            continue

        # Salta l'intestazione del CSV (riga con nomi colonne)
        if len(row) >= 3 and "altitud" in row[2].lower():
            continue

        # Righe con solo 1-2 colonne popolate sono intestazioni di gruppo montuoso
        populated = [cell.strip() for cell in row if cell.strip()]
        if len(populated) <= 2 and len(row) >= 3 and not row[2].strip():
            if populated:
                current_mountain_group = populated[0]
                print(f"    Gruppo montuoso: {current_mountain_group}")
            continue

        # Record valido: deve avere almeno il nome italiano
        if len(row) < 3:
            continue

        name_it = row[0].strip() if len(row) > 0 else ""
        name_de = row[1].strip() if len(row) > 1 else ""
        altitude_str = row[2].strip() if len(row) > 2 else ""
        comune = row[3].strip() if len(row) > 3 else ""
        proprieta = row[4].strip() if len(row) > 4 else ""
        telefono = row[5].strip() if len(row) > 5 else ""
        email = row[6].strip() if len(row) > 6 else ""
        internet = row[7].strip() if len(row) > 7 else ""

        # Salta se non c'e' un nome significativo
        if not name_it and not name_de:
            continue

        # Salta se sembra un'intestazione (no altitudine e no contatti)
        if not altitude_str and not telefono and not email:
            continue

        # Altitudine
        altitude = None
        if altitude_str:
            try:
                cleaned = altitude_str.replace(".", "").replace(",", ".").strip()
                altitude = float(cleaned)
            except (ValueError, TypeError):
                pass

        # Normalizza telefono
        if telefono:
            telefono = clean_phone(telefono)

        # Normalizza URL
        if internet:
            internet = clean_url(internet)

        record = {
            "name_it": name_it,
            "name_de": name_de,
            "altitude": altitude,
            "municipality": comune,
            "owner": proprieta,
            "phone": telefono if telefono else None,
            "email": email if email else None,
            "website": internet if internet else None,
            "mountain_group": current_mountain_group,
            "region": "Trentino-Alto Adige",
            "province": "Bolzano",
        }

        records.append(record)

    return records


def clean_phone(phone):
    """Normalizza numero di telefono."""
    if not phone:
        return None
    # Rimuovi spazi extra, mantieni + e numeri
    cleaned = re.sub(r"[^\d+\-\s/]", "", phone).strip()
    return cleaned if cleaned else None


def clean_url(url):
    """Normalizza URL website."""
    if not url:
        return None
    url = url.strip()
    if url and not url.startswith("http"):
        url = "https://" + url
    return url


# ── Enrichment matching ─────────────────────────────────────────────


def create_enrichment_shelters(records):
    """
    Crea UnifiedShelter "finti" dai record CSV per l'enrichment.

    Siccome il CSV non ha coordinate GPS, usiamo lat=0, lng=0 come placeholder.
    Questi NON saranno aggiunti al dataset come nuove strutture, ma usati
    solo per enrichment name-based nel merge.

    Per il matching nel merge, serve un approccio diverso: il merge_sources.py
    dovra' cercare match per nome (+ altitudine come conferma) invece che per
    coordinate.
    """
    shelters = []

    for record in records:
        name = record["name_it"] or record["name_de"]
        if not name:
            continue

        # Determina tipo dal nome e proprietario
        shelter_type = "rifugio"  # default per i rifugi dell'Alto Adige
        name_lower = name.lower()
        if "bivacco" in name_lower or "biwak" in name_lower:
            shelter_type = "bivacco"
        elif "malga" in name_lower or "alm" in name_lower:
            shelter_type = "malga"

        shelter = UnifiedShelter(
            source="opendata_regional",
            source_id=f"bz-{normalize_name(name)[:30]}",
            name=name,
            lat=0.0,  # No GPS nel CSV
            lng=0.0,  # No GPS nel CSV
            shelter_type=shelter_type,
            country="IT",
            altitude=record.get("altitude"),
            region=record.get("region"),
            province=record.get("province"),
            municipality=record.get("municipality"),
            phone=record.get("phone"),
            email=record.get("email"),
            website=record.get("website"),
            owner=record.get("owner"),
        )
        shelters.append(shelter)

    return shelters


def save_enrichment_data(records, filename):
    """
    Salva i dati di enrichment come JSON nella directory scripts/data/.
    Formato diverso dal save_intermediate standard perche' include
    anche nomi alternativi (DE) per matching.
    """
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    filepath = DATA_DIR / filename

    enrichment_data = []
    for record in records:
        entry = {
            "name_it": record.get("name_it", ""),
            "name_de": record.get("name_de", ""),
            "altitude": record.get("altitude"),
            "municipality": record.get("municipality"),
            "owner": record.get("owner"),
            "phone": record.get("phone"),
            "email": record.get("email"),
            "website": record.get("website"),
            "mountain_group": record.get("mountain_group"),
            "region": record.get("region", "Trentino-Alto Adige"),
            "province": record.get("province", "Bolzano"),
        }
        enrichment_data.append(entry)

    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(enrichment_data, f, ensure_ascii=False, indent=2)

    return filepath


# ── Main ────────────────────────────────────────────────────────────


def main():
    print("=" * 60)
    print("IMPORT OPEN DATA REGIONALI — Enrichment contatti rifugi")
    print("=" * 60)

    # ── Fonte 1: Alto Adige CSV ─────────────────────────────────────

    print("\n" + "-" * 40)
    print("FONTE: Provincia Autonoma di Bolzano")
    print("-" * 40)

    # 1. Fetch CSV
    print("\n1. Download CSV elenco rifugi Alto Adige...")
    csv_content = fetch_csv(SOUTH_TYROL_CSV_URL)
    print(f"   Ricevuti {len(csv_content)} bytes")

    # 2. Parsing
    print("\n2. Parsing CSV (delimitatore punto e virgola)...")
    records = parse_south_tyrol_csv(csv_content)
    print(f"   Estratti: {len(records)} rifugi")

    # 3. Statistiche contatti
    with_phone = sum(1 for r in records if r.get("phone"))
    with_email = sum(1 for r in records if r.get("email"))
    with_website = sum(1 for r in records if r.get("website"))
    with_altitude = sum(1 for r in records if r.get("altitude"))

    print(f"\n3. Disponibilita' dati di contatto:")
    print(f"   Con telefono:  {with_phone}/{len(records)}")
    print(f"   Con email:     {with_email}/{len(records)}")
    print(f"   Con website:   {with_website}/{len(records)}")
    print(f"   Con altitudine: {with_altitude}/{len(records)}")

    # 4. Distribuzione per proprietario
    owner_counts = {}
    for r in records:
        owner = r.get("owner", "N/D") or "N/D"
        owner_counts[owner] = owner_counts.get(owner, 0) + 1
    print(f"\n4. Distribuzione per proprietario:")
    for owner, count in sorted(owner_counts.items(), key=lambda x: -x[1]):
        print(f"   {owner}: {count}")

    # 5. Salva come enrichment data (formato speciale con nomi IT/DE)
    print(f"\n5. Salvataggio enrichment in scripts/data/{OUTPUT_FILE}...")
    filepath = save_enrichment_data(records, OUTPUT_FILE)
    print(f"   Salvato: {filepath}")

    # 6. Salva anche come UnifiedShelter (per il merge name-based)
    print("\n6. Creazione UnifiedShelter per merge name-based...")
    shelters = create_enrichment_shelters(records)
    shelter_filepath = save_intermediate(shelters, "opendata_shelters.json")
    print(f"   Salvato: {shelter_filepath}")

    # 7. Statistiche finali
    print_stats("Open Data Regionali", shelters)

    print(f"\n{'=' * 60}")
    print("IMPORT OPEN DATA completato!")
    print(f"  NOTA: i dati NON hanno coordinate GPS.")
    print(f"  Saranno usati per enrichment (telefono/email/website)")
    print(f"  dei record gia' geolocati da OSM/Wikidata/CAI.")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    main()
