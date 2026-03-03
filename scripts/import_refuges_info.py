#!/usr/bin/env python3
"""
Import rifugi e bivacchi da Refuges.info (API REST).

API: https://www.refuges.info/api/bbox
Formato: GeoJSON FeatureCollection

Zone di query: Alpi italiane di confine (Mont Blanc, Gran Paradiso,
Alpi Marittime, Alpi Pennine, Alpi Lepontine, Alpi Retiche).

Output: scripts/data/refuges_info_shelters.json (formato UnifiedShelter intermedio)

Licenza: CC BY-SA — richiede attribuzione "refuges.info"
"""

import json
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
from pathlib import Path
from typing import Optional

sys.path.insert(0, str(Path(__file__).parent))

from shared import (
    UnifiedShelter,
    normalize_type,
    save_intermediate,
    print_stats,
    haversine_distance,
    normalize_name,
    levenshtein_similarity,
)

# ── Configurazione ──────────────────────────────────────────────────

REFUGES_INFO_API = "https://www.refuges.info/api/bbox"
OUTPUT_FILE = "refuges_info_shelters.json"

USER_AGENT = "RifugiBivacchiBot/1.0 (https://rifugibivacchi.app)"

MAX_RETRIES = 3
RETRY_DELAY_S = 10

# Zone di confine da scansionare.
# Ogni zona e' un bbox [min_lng, min_lat, max_lng, max_lat] con un nome descrittivo.
# Coprono le aree dove i rifugi transfrontalieri sono piu' probabili.
BORDER_ZONES = [
    {
        "name": "Mont Blanc / Aosta Ovest",
        "bbox": [6.6, 45.5, 7.3, 46.1],
    },
    {
        "name": "Gran Paradiso / Aosta Est",
        "bbox": [7.0, 45.3, 7.8, 45.8],
    },
    {
        "name": "Alpi Pennine / Cervino / Monte Rosa",
        "bbox": [7.3, 45.7, 8.2, 46.2],
    },
    {
        "name": "Alpi Lepontine / Sempione / Ticino",
        "bbox": [8.0, 45.9, 9.2, 46.6],
    },
    {
        "name": "Alpi Retiche / Bernina / Engadina",
        "bbox": [9.2, 46.1, 10.6, 46.9],
    },
    {
        "name": "Alpi Marittime / Liguria confine FR",
        "bbox": [7.0, 43.8, 7.8, 44.4],
    },
    {
        "name": "Alto Adige / confine AT",
        "bbox": [10.4, 46.5, 12.5, 47.2],
    },
    {
        "name": "Alpi Giulie / confine SI",
        "bbox": [13.2, 46.2, 14.0, 46.7],
    },
]


# ── Fetch API ───────────────────────────────────────────────────────


def fetch_refuges_bbox(bbox: list) -> dict:
    """
    Query l'API di refuges.info per un bounding box.
    bbox: [min_lng, min_lat, max_lng, max_lat]
    Restituisce GeoJSON FeatureCollection.
    """
    params = urllib.parse.urlencode(
        {
            "bbox": f"{bbox[0]},{bbox[1]},{bbox[2]},{bbox[3]}",
            "type_points": "refuge,cabane,gite,abri",  # Tutti i tipi rifugio
            "format": "geojson",
        }
    )
    url = f"{REFUGES_INFO_API}?{params}"

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": USER_AGENT},
            )
            with urllib.request.urlopen(req, timeout=60) as resp:
                raw = resp.read().decode("utf-8")
                return json.loads(raw)

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

    return {"type": "FeatureCollection", "features": []}


# ── Parsing GeoJSON ─────────────────────────────────────────────────


def parse_refuges_type(properties: dict) -> str:
    """
    Determina il tipo di struttura dai dati Refuges.info.

    Il campo type.valeur contiene:
    - "refuge gardé" → rifugio
    - "refuge non gardé" → rifugio
    - "cabane non gardée" → bivacco
    - "gîte d'étape" → rifugio
    - "abri" → bivacco

    Il campo type.icone puo' avere suffissi che indicano servizi:
    - feu (fuoco/riscaldamento)
    - eau (acqua)
    - cle (chiave necessaria)
    """
    type_info = properties.get("type", {})
    type_valeur = type_info.get("valeur", "")
    name = properties.get("nom", "")

    return normalize_type(type_valeur, name)


def parse_services_from_icon(icon: str) -> dict:
    """
    Decodifica i suffissi dell'icona per determinare i servizi.
    Es: "cabane_feu_eau" → fuoco e acqua disponibili
    """
    icon_lower = (icon or "").lower()
    services = {}

    if "feu" in icon_lower:
        services["electricity"] = True  # fuoco/riscaldamento ~ energia
    if "eau" in icon_lower:
        services["hot_water"] = False  # acqua presente, ma non calda
    if "cle" in icon_lower:
        services["locked"] = True  # necessaria chiave

    return services


def parse_status(properties: dict) -> Optional[str]:
    """
    Determina lo stato della struttura.
    etat.valeur: "" (aperto), "Détruite" (distrutta), "Fermée" (chiusa)
    """
    etat = properties.get("etat", {})
    etat_valeur = etat.get("valeur", "")

    if not etat_valeur:
        return None  # aperto, nessuno stato speciale
    if "truite" in etat_valeur.lower():
        return "Distrutto"
    if "erm" in etat_valeur.lower():
        return "Chiuso"

    return etat_valeur


def detect_country_from_coords(lat: float, lng: float) -> str:
    """Stima il paese dalle coordinate (confini alpini approssimativi)."""
    if lat > 47.0 and lng > 10.5:
        return "AT"
    if lat > 46.8 and lng < 10.5 and lng > 7.5:
        return "CH"
    if lat > 46.5 and lng > 13.7 and lat > 46.6:
        return "SI"
    if lat > 46.0 and lng < 7.0:
        return "FR"
    if lat < 44.0 and lng < 7.5:
        return "FR"  # Nizzardo / Alpi Marittime lato FR

    return "IT"


def parse_feature(feature: dict) -> Optional[UnifiedShelter]:
    """
    Converte un feature GeoJSON di refuges.info in UnifiedShelter.
    """
    properties = feature.get("properties", {})
    geometry = feature.get("geometry", {})

    name = properties.get("nom", "").strip()
    if not name:
        return None

    # Coordinate: GeoJSON e' [lng, lat]
    coords = geometry.get("coordinates", [])
    if len(coords) < 2:
        return None

    lng = coords[0]
    lat = coords[1]

    if not (-90 <= lat <= 90 and -180 <= lng <= 180):
        return None

    # Source ID
    source_id = str(properties.get("id", ""))
    if not source_id:
        return None

    # Tipo
    shelter_type = parse_refuges_type(properties)

    # Altitudine
    altitude = None
    coord_info = properties.get("coord", {})
    alt_val = coord_info.get("alt")
    if alt_val is not None:
        try:
            altitude = float(alt_val)
        except (ValueError, TypeError):
            pass

    # Capacita' (posti)
    capacity = None
    places = properties.get("places", {})
    if places:
        places_val = places.get("valeur")
        if places_val is not None:
            try:
                capacity = int(places_val)
            except (ValueError, TypeError):
                pass

    # Stato
    status = parse_status(properties)

    # Servizi dall'icona
    icon = properties.get("type", {}).get("icone", "")
    services = parse_services_from_icon(icon)

    # Paese
    country = detect_country_from_coords(lat, lng)

    # Link alla pagina su refuges.info
    lien = properties.get("lien")
    website = f"https://www.refuges.info{lien}" if lien else None

    return UnifiedShelter(
        source="refuges.info",
        source_id=source_id,
        name=name,
        lat=lat,
        lng=lng,
        shelter_type=shelter_type,
        country=country,
        altitude=altitude,
        capacity=capacity,
        status=status,
        electricity=services.get("electricity"),
        hot_water=services.get("hot_water"),
        website=website,
    )


# ── Deduplicazione interna ──────────────────────────────────────────


def dedup_internal(shelters: list) -> list:
    """
    Rimuove duplicati interni (zone di query sovrapposte
    possono restituire lo stesso rifugio piu' volte).
    """
    seen_ids = set()
    unique = []

    for s in shelters:
        if s.source_id in seen_ids:
            continue
        seen_ids.add(s.source_id)
        unique.append(s)

    return unique


# ── Validazione ─────────────────────────────────────────────────────


def validate_shelters(shelters: list) -> list:
    """Filtra shelter con dati validi."""
    valid = []
    skipped_destroyed = 0
    skipped_coords = 0

    for s in shelters:
        # Salta strutture distrutte
        if s.status == "Distrutto":
            skipped_destroyed += 1
            continue

        # Coordinate ragionevoli per le Alpi
        if not (35.0 <= s.lat <= 48.0 and 5.0 <= s.lng <= 19.0):
            skipped_coords += 1
            continue

        # Altitudine ragionevole
        if s.altitude is not None and (s.altitude < 0 or s.altitude > 5000):
            s.altitude = None

        valid.append(s)

    if skipped_destroyed > 0:
        print(f"  Scartati {skipped_destroyed} strutture distrutte")
    if skipped_coords > 0:
        print(f"  Scartati {skipped_coords} per coordinate fuori range")

    return valid


# ── Main ────────────────────────────────────────────────────────────


def main():
    print("=" * 60)
    print("IMPORT REFUGES.INFO — Rifugi di confine IT/FR/CH/AT/SI")
    print("=" * 60)

    # 1. Fetch per ogni zona di confine
    print("\n1. Query API Refuges.info per zona...")
    all_shelters = []

    for zone in BORDER_ZONES:
        name = zone["name"]
        bbox = zone["bbox"]
        print(f"\n   → {name} [{bbox}]...")

        try:
            geojson = fetch_refuges_bbox(bbox)
            features = geojson.get("features", [])
            print(f"     Ricevuti {len(features)} feature")

            parsed = 0
            for feature in features:
                shelter = parse_feature(feature)
                if shelter:
                    all_shelters.append(shelter)
                    parsed += 1
            print(f"     Parsed: {parsed} strutture con nome")

        except Exception as e:
            print(f"     ERRORE: {e} — continuo con le altre zone")

        # Pausa tra le richieste
        time.sleep(1)

    print(f"\n   Totale raw: {len(all_shelters)} strutture")

    # 2. Deduplicazione interna (zone sovrapposte)
    print("\n2. Deduplicazione interna...")
    before_dedup = len(all_shelters)
    all_shelters = dedup_internal(all_shelters)
    print(
        f"   Rimossi {before_dedup - len(all_shelters)} duplicati da zone sovrapposte"
    )
    print(f"   Unici: {len(all_shelters)}")

    # 3. Validazione
    print("\n3. Validazione...")
    all_shelters = validate_shelters(all_shelters)
    print(f"   Validi: {len(all_shelters)} strutture")

    # 4. Distribuzione per paese
    country_counts = {}
    for s in all_shelters:
        country_counts[s.country] = country_counts.get(s.country, 0) + 1
    print("\n4. Distribuzione per paese:")
    for country, count in sorted(country_counts.items(), key=lambda x: -x[1]):
        print(f"   {country}: {count}")

    # 5. Salvataggio
    print(f"\n5. Salvataggio in scripts/data/{OUTPUT_FILE}...")
    filepath = save_intermediate(all_shelters, OUTPUT_FILE)
    print(f"   Salvato: {filepath}")

    # 6. Statistiche finali
    print_stats("Refuges.info", all_shelters)

    print(f"\n{'=' * 60}")
    print("IMPORT REFUGES.INFO completato!")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    main()
