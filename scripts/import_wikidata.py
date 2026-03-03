#!/usr/bin/env python3
"""
Import rifugi e bivacchi da Wikidata + immagini Wikimedia Commons.

Query SPARQL per:
  - Q182676 (rifugio alpino / alpine hut)
  - Q22698 (bivacco / bivouac shelter)
  - Q3947 (capanna / hut) con coordinate in Italia

Arricchimento: immagini da Wikimedia Commons (campo mediaList).

Output: scripts/data/wikidata_shelters.json (formato UnifiedShelter intermedio)

Licenza: CC0 (dati Wikidata), licenze varie per immagini Commons (quasi tutte CC BY-SA)
"""

import json
import re
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
from pathlib import Path
from typing import Optional

sys.path.insert(0, str(Path(__file__).parent))

from shared import (
    ITALY_BBOX,
    UnifiedShelter,
    normalize_type,
    save_intermediate,
    print_stats,
)

# ── Configurazione ──────────────────────────────────────────────────

WIKIDATA_SPARQL_URL = "https://query.wikidata.org/sparql"
OUTPUT_FILE = "wikidata_shelters.json"

# User-Agent richiesto dalla policy di Wikidata
USER_AGENT = (
    "RifugiBivacchiBot/1.0 (https://rifugibivacchi.app; info@rifugibivacchi.app)"
)

# Retry configuration
MAX_RETRIES = 3
RETRY_DELAY_S = 15


# ── Query SPARQL ────────────────────────────────────────────────────


def build_sparql_queries() -> list:
    """
    Costruisce query SPARQL separate per ogni tipo di struttura.

    Splitting in query più piccole per evitare timeout del SPARQL endpoint.
    Usiamo P31 diretto (istanza di) senza P279* (sottoclassi ricorsive)
    per velocizzare l'esecuzione.

    Tipi cercati:
    - Q182676 (rifugio alpino / alpine hut)
    - Q22698 (bivacco / bivouac shelter)
    - Q3947 (capanna / mountain hut)
    - Q2948402 (bivacco fisso)
    - Q106589819 (rifugio escursionistico)
    """
    bbox = ITALY_BBOX

    # Tipi diretti da cercare: ID Wikidata → etichetta per logging
    shelter_types = [
        ("Q182676", "rifugio alpino"),
        ("Q22698", "bivacco"),
        ("Q3947", "capanna"),
        ("Q2948402", "bivacco fisso"),
        ("Q106589819", "rifugio escursionistico"),
    ]

    queries = []
    for qid, label in shelter_types:
        query = f"""
SELECT DISTINCT ?shelter ?shelterLabel ?coord ?elevation ?image ?instanceOf ?instanceOfLabel ?countryLabel ?website WHERE {{
  ?shelter wdt:P31 wd:{qid} .
  ?shelter wdt:P625 ?coord .
  BIND(wd:{qid} AS ?instanceOf)

  FILTER(
    (geof:latitude(?coord) >= {bbox["min_lat"]}) &&
    (geof:latitude(?coord) <= {bbox["max_lat"]}) &&
    (geof:longitude(?coord) >= {bbox["min_lng"]}) &&
    (geof:longitude(?coord) <= {bbox["max_lng"]})
  )

  OPTIONAL {{ ?shelter wdt:P2044 ?elevation . }}
  OPTIONAL {{ ?shelter wdt:P18 ?image . }}
  OPTIONAL {{ ?shelter wdt:P17 ?country . }}
  OPTIONAL {{ ?shelter wdt:P856 ?website . }}

  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "it,en,de,fr" . }}
}}
"""
        queries.append((qid, label, query.strip()))

    return queries


def fetch_sparql(query: str) -> dict:
    """
    Esegue una query SPARQL su Wikidata con retry.
    """
    params = urllib.parse.urlencode({"query": query, "format": "json"})
    url = f"{WIKIDATA_SPARQL_URL}?{params}"

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            print(f"  Wikidata SPARQL: tentativo {attempt}/{MAX_RETRIES}...")
            req = urllib.request.Request(
                url,
                headers={
                    "Accept": "application/sparql-results+json",
                    "User-Agent": USER_AGENT,
                },
            )
            with urllib.request.urlopen(req, timeout=120) as resp:
                raw = resp.read().decode("utf-8")
                return json.loads(raw)

        except urllib.error.HTTPError as e:
            if e.code in (429, 503, 504):
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

    print("  ERRORE: tutti i tentativi SPARQL falliti")
    sys.exit(1)


# ── Parsing risultati SPARQL ────────────────────────────────────────


def parse_wkt_point(wkt: str) -> tuple:
    """
    Parsing di coordinate WKT Point.
    Formato: "Point(lon lat)" -> (lat, lng)
    """
    match = re.search(r"Point\(([-\d.]+)\s+([-\d.]+)\)", wkt)
    if not match:
        return None, None

    lng = float(match.group(1))
    lat = float(match.group(2))
    return lat, lng


def extract_wikidata_id(uri: str) -> str:
    """Estrae l'ID Wikidata da un URI (es. 'http://www.wikidata.org/entity/Q123' -> 'Q123')"""
    if not uri:
        return ""
    return uri.rsplit("/", 1)[-1]


def wikimedia_commons_url(image_uri: str) -> str:
    """
    Converte un URI Wikimedia Commons in URL diretto dell'immagine.
    Input:  'http://commons.wikimedia.org/wiki/Special:FilePath/Nome%20File.jpg'
    Output: URL diretto (lo stesso, e' gia usabile come img src)
    """
    if not image_uri:
        return ""
    # L'URI restituito da Wikidata e' gia un URL valido
    return image_uri


def determine_type_from_wikidata(instance_of_label: str, name: str) -> str:
    """
    Determina il tipo di rifugio basandosi sull'instanceOf di Wikidata.
    """
    label_lower = (instance_of_label or "").lower()

    if "bivac" in label_lower or "bivouac" in label_lower or "biwak" in label_lower:
        return "bivacco"
    if "capanna" in label_lower or "hütte" in label_lower or "cabane" in label_lower:
        return normalize_type("", name)
    if "rifugio" in label_lower or "refuge" in label_lower:
        return "rifugio"
    if "malga" in label_lower or "alm" in label_lower:
        return "malga"

    return normalize_type("", name)


def detect_country_from_wikidata(country_label: str, lat: float, lng: float) -> str:
    """Rileva il paese dall'etichetta Wikidata o dalle coordinate."""
    label_lower = (country_label or "").lower()

    country_map = {
        "italia": "IT",
        "italy": "IT",
        "svizzera": "CH",
        "switzerland": "CH",
        "schweiz": "CH",
        "austria": "AT",
        "österreich": "AT",
        "francia": "FR",
        "france": "FR",
        "slovenia": "SI",
    }

    for key, code in country_map.items():
        if key in label_lower:
            return code

    # Fallback: stima da coordinate (semplificata)
    if lat > 47.0 and lng > 10.5:
        return "AT"
    if lat > 46.8 and lng < 10.5:
        return "CH"
    if lat > 46.0 and lng < 7.0:
        return "FR"
    if lat > 46.5 and lng > 13.7:
        return "SI"

    return "IT"


def parse_bindings(bindings: list) -> list:
    """
    Converte i risultati SPARQL in UnifiedShelter.
    Gestisce duplicati (stesso shelter con piu' immagini/tipi).
    """
    # Raggruppa per shelter URI (un rifugio puo' avere piu' risultati con immagini diverse)
    shelter_map = {}

    for binding in bindings:
        shelter_uri = binding.get("shelter", {}).get("value", "")
        wikidata_id = extract_wikidata_id(shelter_uri)

        if not wikidata_id:
            continue

        name = binding.get("shelterLabel", {}).get("value", "")
        if not name or name == wikidata_id:
            # Il label non e' stato risolto, salta
            continue

        coord_wkt = binding.get("coord", {}).get("value", "")
        lat, lng = parse_wkt_point(coord_wkt)
        if lat is None or lng is None:
            continue

        # Se gia' visto, aggiungi solo l'immagine
        if wikidata_id in shelter_map:
            image_uri = binding.get("image", {}).get("value", "")
            if image_uri:
                url = wikimedia_commons_url(image_uri)
                if url and url not in shelter_map[wikidata_id]["image_urls"]:
                    shelter_map[wikidata_id]["image_urls"].append(url)
            continue

        # Nuovo shelter
        elevation = None
        ele_val = binding.get("elevation", {}).get("value")
        if ele_val:
            try:
                elevation = float(ele_val)
            except (ValueError, TypeError):
                pass

        image_urls = []
        image_uri = binding.get("image", {}).get("value", "")
        if image_uri:
            url = wikimedia_commons_url(image_uri)
            if url:
                image_urls.append(url)

        instance_label = binding.get("instanceOfLabel", {}).get("value", "")
        country_label = binding.get("countryLabel", {}).get("value", "")
        website = binding.get("website", {}).get("value", "")

        shelter_map[wikidata_id] = {
            "wikidata_id": wikidata_id,
            "name": name,
            "lat": lat,
            "lng": lng,
            "elevation": elevation,
            "image_urls": image_urls,
            "instance_label": instance_label,
            "country_label": country_label,
            "website": website,
        }

    # Converti in UnifiedShelter
    shelters = []
    for wid, data in shelter_map.items():
        shelter_type = determine_type_from_wikidata(
            data["instance_label"], data["name"]
        )
        country = detect_country_from_wikidata(
            data["country_label"], data["lat"], data["lng"]
        )

        shelters.append(
            UnifiedShelter(
                source="wikidata",
                source_id=wid,
                name=data["name"],
                lat=data["lat"],
                lng=data["lng"],
                shelter_type=shelter_type,
                country=country,
                altitude=data["elevation"],
                website=data["website"] or None,
                image_urls=data["image_urls"],
            )
        )

    return shelters


# ── Validazione ─────────────────────────────────────────────────────


def validate_shelters(shelters: list) -> list:
    """Filtra shelter con dati validi."""
    valid = []
    skipped = 0

    for s in shelters:
        # Coordinate ragionevoli
        if not (35.0 <= s.lat <= 48.0 and 5.0 <= s.lng <= 19.0):
            skipped += 1
            continue

        # Altitudine ragionevole (se presente)
        if s.altitude is not None and (s.altitude < 0 or s.altitude > 5000):
            s.altitude = None

        valid.append(s)

    if skipped > 0:
        print(f"  Scartati {skipped} per coordinate fuori range")

    return valid


# ── Main ────────────────────────────────────────────────────────────


def main():
    print("=" * 60)
    print("IMPORT WIKIDATA — Rifugi e Bivacchi da Wikidata + Commons")
    print("=" * 60)

    # 1. Query SPARQL (una per tipo, per evitare timeout)
    print("\n1. Query SPARQL Wikidata (per tipo)...")
    queries = build_sparql_queries()

    all_bindings = []
    for qid, label, query in queries:
        print(f"\n   → {label} ({qid})...")
        try:
            response = fetch_sparql(query)
            bindings = response.get("results", {}).get("bindings", [])
            print(f"     Ricevuti {len(bindings)} binding")
            all_bindings.extend(bindings)
        except Exception as e:
            print(f"     ERRORE per {label}: {e} — continuo con le altre fonti")

        # Pausa tra le query per rispettare i rate limit di Wikidata
        time.sleep(2)

    print(f"\n   Totale binding raccolti: {len(all_bindings)}")

    # 2. Parsing e deduplicazione interna
    print("\n2. Parsing risultati...")
    shelters = parse_bindings(all_bindings)
    print(f"   Parsed: {len(shelters)} strutture uniche")

    # 3. Validazione
    print("\n3. Validazione...")
    shelters = validate_shelters(shelters)
    print(f"   Validi: {len(shelters)} strutture")

    # 4. Statistiche immagini
    with_images = sum(1 for s in shelters if s.image_urls)
    total_images = sum(len(s.image_urls) for s in shelters)
    print(f"\n4. Immagini:")
    print(f"   Strutture con immagini: {with_images}/{len(shelters)}")
    print(f"   Totale immagini: {total_images}")

    # 5. Distribuzione per paese
    country_counts = {}
    for s in shelters:
        country_counts[s.country] = country_counts.get(s.country, 0) + 1
    print("\n5. Distribuzione per paese:")
    for country, count in sorted(country_counts.items(), key=lambda x: -x[1]):
        print(f"   {country}: {count}")

    # 6. Salvataggio
    print(f"\n6. Salvataggio in scripts/data/{OUTPUT_FILE}...")
    filepath = save_intermediate(shelters, OUTPUT_FILE)
    print(f"   Salvato: {filepath}")

    # 7. Statistiche finali
    print_stats("Wikidata", shelters)

    print(f"\n{'=' * 60}")
    print("IMPORT WIKIDATA completato!")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    main()
