#!/usr/bin/env python3
"""
Import rifugi e bivacchi da OpenStreetMap (Overpass API).

Query per tag:
  - tourism=alpine_hut (rifugi custoditi)
  - tourism=wilderness_hut (bivacchi / rifugi incustoditi)

Bounding box: Italia estesa (include zone di confine con FR/CH/AT/SI).

Output: scripts/data/osm_shelters.json (formato UnifiedShelter intermedio)

Licenza dati: ODbL - richiede attribuzione "OpenStreetMap contributors"
"""

import json
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
from pathlib import Path
from typing import Optional

# Aggiungi la directory scripts al path per importare shared
sys.path.insert(0, str(Path(__file__).parent))

from shared import (
    ITALY_BBOX,
    UnifiedShelter,
    normalize_type,
    save_intermediate,
    print_stats,
)

# ── Configurazione ──────────────────────────────────────────────────

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
OUTPUT_FILE = "osm_shelters.json"

# Timeout per la query Overpass (secondi)
OVERPASS_TIMEOUT = 120

# Retry configuration
MAX_RETRIES = 3
RETRY_DELAY_S = 10


# ── Query Overpass ──────────────────────────────────────────────────


def build_overpass_query() -> str:
    """
    Costruisce la query Overpass QL per estrarre rifugi e bivacchi
    nel bounding box dell'Italia.
    """
    bbox = (
        f"{ITALY_BBOX['min_lat']},{ITALY_BBOX['min_lng']},"
        f"{ITALY_BBOX['max_lat']},{ITALY_BBOX['max_lng']}"
    )

    # Query per nodi e way con tourism=alpine_hut o wilderness_hut
    # I way vengono convertiti in centroide con `out center`
    query = f"""
[out:json][timeout:{OVERPASS_TIMEOUT}];
(
  node["tourism"="alpine_hut"]({bbox});
  way["tourism"="alpine_hut"]({bbox});
  node["tourism"="wilderness_hut"]({bbox});
  way["tourism"="wilderness_hut"]({bbox});
);
out center tags;
"""
    return query.strip()


def fetch_overpass(query: str) -> dict:
    """
    Esegue una query sull'Overpass API con retry.
    Restituisce il JSON di risposta.
    """
    data = f"data={urllib.parse.quote(query)}".encode("utf-8")

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            print(f"  Overpass API: tentativo {attempt}/{MAX_RETRIES}...")
            req = urllib.request.Request(
                OVERPASS_URL,
                data=data,
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
            with urllib.request.urlopen(req, timeout=OVERPASS_TIMEOUT + 30) as resp:
                raw = resp.read().decode("utf-8")
                return json.loads(raw)

        except urllib.error.HTTPError as e:
            if e.code == 429 or e.code == 504:
                wait = RETRY_DELAY_S * attempt
                print(f"  HTTP {e.code} — attendo {wait}s prima di riprovare...")
                time.sleep(wait)
            else:
                print(f"  ERRORE HTTP {e.code}: {e.reason}")
                raise
        except urllib.error.URLError as e:
            print(f"  ERRORE connessione: {e.reason}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY_S)
            else:
                raise

    print("  ERRORE: tutti i tentativi Overpass falliti")
    sys.exit(1)


# ── Parsing elementi OSM ───────────────────────────────────────────


def parse_element(element: dict) -> Optional[UnifiedShelter]:
    """
    Converte un elemento Overpass in UnifiedShelter.
    Restituisce None se l'elemento non ha dati sufficienti.
    """
    tags = element.get("tags", {})
    name = tags.get("name", "").strip()

    # Salta elementi senza nome (non utilizzabili)
    if not name:
        return None

    # Coordinate: per i nodi sono dirette, per i way usiamo il centroide
    if element["type"] == "node":
        lat = element.get("lat")
        lng = element.get("lon")
    elif element["type"] == "way":
        center = element.get("center", {})
        lat = center.get("lat")
        lng = center.get("lon")
    else:
        return None

    if lat is None or lng is None:
        return None

    # Source ID nel formato "type/id" (es. "node/12345678")
    source_id = f"{element['type']}/{element['id']}"

    # Tipo struttura
    tourism_tag = tags.get("tourism", "alpine_hut")
    shelter_type = normalize_type(tourism_tag, name)

    # Altitudine
    altitude = None
    ele_str = tags.get("ele", "")
    if ele_str:
        try:
            # OSM ele e' una stringa, spesso con unita' (es. "2345", "2345 m")
            cleaned = ele_str.replace("m", "").replace(",", ".").strip()
            altitude = float(cleaned)
        except (ValueError, TypeError):
            pass

    # Capacita' (posti letto)
    capacity = None
    cap_str = tags.get("capacity", "") or tags.get("beds", "")
    if cap_str:
        try:
            capacity = int(cap_str)
        except (ValueError, TypeError):
            pass

    # Contatti
    phone = tags.get("phone") or tags.get("contact:phone")
    email = tags.get("email") or tags.get("contact:email")
    website = tags.get("website") or tags.get("contact:website") or tags.get("url")

    # Operatore / proprietario
    operator = tags.get("operator")
    owner_tag = tags.get("owner")

    # Stato (aperto/chiuso)
    status = None
    if tags.get("disused") == "yes" or tags.get("abandoned") == "yes":
        status = "Chiuso"
    elif tags.get("access") == "no":
        status = "Accesso limitato"

    # Servizi deducibili dai tag OSM
    restaurant = None
    if tags.get("restaurant") == "yes" or tags.get("bar") == "yes":
        restaurant = True
    elif tags.get("self_catering") == "yes":
        restaurant = False

    electricity = None
    if tags.get("power_supply") == "yes" or tags.get("electricity") == "yes":
        electricity = True
    elif tags.get("power_supply") == "no":
        electricity = False

    showers = None
    if tags.get("shower") == "yes":
        showers = True
    elif tags.get("shower") == "no":
        showers = False

    # Immagini: Wikimedia Commons da tag
    image_urls = []
    wikimedia_commons = tags.get("wikimedia_commons")
    if wikimedia_commons:
        # Il tag contiene il nome del file su Commons
        # Formato URL diretto non sempre funziona, salviamo il riferimento
        image_urls.append(
            f"https://commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(wikimedia_commons)}"
        )
    image_tag = tags.get("image")
    if image_tag and image_tag.startswith("http"):
        image_urls.append(image_tag)

    return UnifiedShelter(
        source="openstreetmap",
        source_id=source_id,
        name=name,
        lat=lat,
        lng=lng,
        shelter_type=shelter_type,
        country=detect_country(lat, lng),
        altitude=altitude,
        capacity=capacity,
        phone=phone,
        email=email,
        website=website,
        operator=operator,
        owner=owner_tag,
        status=status,
        restaurant=restaurant,
        electricity=electricity,
        showers=showers,
        image_urls=image_urls,
    )


def detect_country(lat: float, lng: float) -> str:
    """
    Stima approssimativa del paese basata sulle coordinate.
    Per la zona alpina, usa bounding box semplificati.
    """
    # Italia continentale (approssimazione generosa)
    if 36.0 <= lat <= 47.2 and 6.6 <= lng <= 18.6:
        # Ma la fascia nord include parti di CH/AT/SI/FR
        # Zone chiaramente non italiane:
        if lat > 46.6 and lng < 10.5 and lat > 46.8:
            return "CH"  # Svizzera (Ticino/Grigioni)
        if lat > 47.0 and lng > 10.5:
            return "AT"  # Austria
        if lat > 46.5 and lng > 13.7 and lat > 46.6:
            return "SI"  # Slovenia
        if lat > 46.0 and lng < 7.0:
            return "FR"  # Francia (Savoia)
        return "IT"

    # Fuori dal bounding box Italia
    if lat > 46.0 and 5.5 <= lng <= 7.5:
        return "FR"
    if lat > 46.5 and 7.5 <= lng <= 10.5:
        return "CH"
    if lat > 46.8 and 10.5 <= lng <= 16.0:
        return "AT"
    if lat > 45.5 and lng > 13.5:
        return "SI"

    return "IT"  # default


# ── Validazione ─────────────────────────────────────────────────────


def validate_shelters(shelters: list[UnifiedShelter]) -> list[UnifiedShelter]:
    """
    Filtra gli shelter con dati minimi validi e rimuove duplicati OSM
    (stesso nome a <50m, che capita con node+way per la stessa struttura).
    """
    valid = []
    skipped_invalid = 0
    skipped_osm_dupes = 0

    for s in shelters:
        # Coordinate valide
        if not (-90 <= s.lat <= 90 and -180 <= s.lng <= 180):
            skipped_invalid += 1
            continue

        # Altitudine ragionevole per le Alpi (se presente)
        if s.altitude is not None and (s.altitude < 0 or s.altitude > 5000):
            s.altitude = None  # rimuovi ma non scartare lo shelter

        # Dedup interna OSM: node e way per la stessa struttura
        is_osm_dupe = False
        for existing in valid:
            from shared import (
                haversine_distance,
                normalize_name,
                levenshtein_similarity,
            )

            dist = haversine_distance(s.lat, s.lng, existing.lat, existing.lng)
            if dist < 50:  # 50m per dedup interna OSM (piu' stretto)
                name_sim = levenshtein_similarity(
                    normalize_name(s.name), normalize_name(existing.name)
                )
                if name_sim >= 0.85:
                    is_osm_dupe = True
                    break

        if is_osm_dupe:
            skipped_osm_dupes += 1
            continue

        valid.append(s)

    if skipped_invalid > 0:
        print(f"  Scartati {skipped_invalid} per coordinate invalide")
    if skipped_osm_dupes > 0:
        print(f"  Rimossi {skipped_osm_dupes} duplicati interni OSM (node/way)")

    return valid


# ── Main ────────────────────────────────────────────────────────────


def main():
    print("=" * 60)
    print("IMPORT OSM — Rifugi e Bivacchi da OpenStreetMap")
    print("=" * 60)

    # 1. Query Overpass
    print("\n1. Query Overpass API...")
    query = build_overpass_query()
    response = fetch_overpass(query)

    elements = response.get("elements", [])
    print(f"   Ricevuti {len(elements)} elementi da Overpass")

    # Statistiche raw per tipo
    type_counts = {}
    for el in elements:
        tag = el.get("tags", {}).get("tourism", "unknown")
        type_counts[tag] = type_counts.get(tag, 0) + 1
    for tag, count in sorted(type_counts.items()):
        print(f"   - {tag}: {count}")

    # 2. Parsing
    print("\n2. Parsing elementi...")
    shelters = []
    skipped_no_name = 0

    for element in elements:
        shelter = parse_element(element)
        if shelter:
            shelters.append(shelter)
        else:
            skipped_no_name += 1

    print(f"   Parsed: {len(shelters)} strutture con nome")
    if skipped_no_name > 0:
        print(f"   Scartati: {skipped_no_name} senza nome")

    # 3. Validazione e dedup interna
    print("\n3. Validazione e dedup interna...")
    shelters = validate_shelters(shelters)
    print(f"   Validi: {len(shelters)} strutture")

    # 4. Statistiche paese
    country_counts = {}
    for s in shelters:
        country_counts[s.country] = country_counts.get(s.country, 0) + 1
    print("\n4. Distribuzione per paese:")
    for country, count in sorted(country_counts.items(), key=lambda x: -x[1]):
        print(f"   {country}: {count}")

    # 5. Salvataggio
    print(f"\n5. Salvataggio in scripts/data/{OUTPUT_FILE}...")
    filepath = save_intermediate(shelters, OUTPUT_FILE)
    print(f"   Salvato: {filepath}")

    # 6. Statistiche finali
    print_stats("OpenStreetMap", shelters)

    print(f"\n{'=' * 60}")
    print("IMPORT OSM completato!")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    main()
