#!/usr/bin/env python3
"""
Import capanne ticinesi da capanneti.ch (web scraping HTML).

Fonte: https://www.capanneti.ch/it/capanne
Struttura: pagina singola con tutte le 88 capanne del Ticino e Moesano.
I dati essenziali sono embedded negli attributi HTML data-* di ogni card div.

Dati estratti:
- Nome, coordinate (lat/lng), immagine, stato (Custodita/Non custodita)
- Capacita' (posti letto) e localita' (regione, valle) dal testo interno
- Link alla pagina di dettaglio

Output: scripts/data/capanneti_shelters.json (formato UnifiedShelter intermedio)

Licenza: da verificare — sito non-profit, contattare per permesso.
"""

import html
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
    normalize_type,
    save_intermediate,
    print_stats,
)

# ── Configurazione ──────────────────────────────────────────────────

CAPANNETI_URL = "https://www.capanneti.ch/it/capanne"
OUTPUT_FILE = "capanneti_shelters.json"

USER_AGENT = "RifugiBivacchiBot/1.0 (https://rifugibivacchi.app)"

MAX_RETRIES = 3
RETRY_DELAY_S = 10

# Base URL per le immagini (relative nel sorgente HTML)
BASE_URL = "https://www.capanneti.ch"


# ── Fetch HTML ──────────────────────────────────────────────────────


def fetch_page() -> str:
    """
    Scarica la pagina HTML della lista capanne da capanneti.ch.
    """
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            print(f"  Fetch pagina: tentativo {attempt}/{MAX_RETRIES}...")
            req = urllib.request.Request(
                CAPANNETI_URL,
                headers={"User-Agent": USER_AGENT},
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                return resp.read().decode("utf-8")

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


# ── Parsing HTML ────────────────────────────────────────────────────


def decode_html_entities(text):
    """Decodifica entita' HTML (es. &#252; -> u-umlaut, &#232; -> e-grave)."""
    if not text:
        return text
    return html.unescape(text)


def parse_huts_from_html(html_content):
    """
    Estrae le capanne dalla pagina HTML usando regex sui data-* attributes.

    Ogni capanna e' un div con classe "post-05" e questi attributi:
      data-marker-id="N"
      data-lat="46.xxxxx"
      data-lng="8.xxxxx"
      data-img="/media/..."
      data-name="Nome Capanna"
      data-link="/it/capanne/nome-capanna"
      data-status="Custodita" o "Non custodita"
      data-status-class="online" (per custodite) o "" (per non custodite)

    All'interno del div:
      <div class="post-05__location">X posti</div>
      <div class="post-05__location">Regione , Valle</div>
    """
    shelters = []

    # Pattern per trovare ogni card div con data-* attributes
    # Usiamo un approccio a due fasi: prima troviamo ogni blocco card,
    # poi estraiamo i singoli attributi dal blocco
    card_pattern = re.compile(
        r'<div[^>]+class="[^"]*post-05[^"]*"[^>]*'
        r'data-marker-id="[^"]*"[^>]*'
        r'data-lat="([^"]*)"[^>]*'
        r'data-lng="([^"]*)"[^>]*'
        r'data-img="([^"]*)"[^>]*'
        r'data-name="([^"]*)"[^>]*'
        r'data-link="([^"]*)"[^>]*'
        r'data-status="([^"]*)"',
        re.DOTALL,
    )

    # Pattern alternativo piu' flessibile: gli attributi data-* possono
    # essere in ordine diverso, quindi estraiamo il blocco div intero
    # e poi cerchiamo ogni attributo individualmente
    div_pattern = re.compile(
        r'<div[^>]+class="[^"]*post-05[^"]*"[^>]+data-marker-id="[^"]*"[^>]*>',
        re.DOTALL,
    )

    # Prima proviamo il pattern specifico (ordine noto)
    matches = card_pattern.findall(html_content)

    if not matches:
        # Fallback: trova ogni div card e estrai attributi singolarmente
        print("  Pattern specifico non trovato, uso fallback flessibile...")
        matches = parse_huts_flexible(html_content)

    for match in matches:
        if isinstance(match, tuple) and len(match) >= 6:
            lat_str, lng_str, img_path, name_raw, link, status_raw = match[:6]
        elif isinstance(match, dict):
            lat_str = match.get("lat", "")
            lng_str = match.get("lng", "")
            img_path = match.get("img", "")
            name_raw = match.get("name", "")
            link = match.get("link", "")
            status_raw = match.get("status", "")
        else:
            continue

        shelter = parse_single_hut(
            lat_str, lng_str, img_path, name_raw, link, status_raw, html_content
        )
        if shelter:
            shelters.append(shelter)

    return shelters


def parse_huts_flexible(html_content):
    """
    Fallback: trova ogni div con data-marker-id e estrae gli attributi
    individualmente. Piu' robusto se l'ordine degli attributi cambia.
    """
    results = []

    # Trova tutti i div con classe post-05 e data-marker-id
    div_pattern = re.compile(
        r'<div\s[^>]*class="[^"]*post-05[^"]*"[^>]*data-marker-id="[^"]*"[^>]*>',
        re.DOTALL,
    )

    for div_match in div_pattern.finditer(html_content):
        div_tag = div_match.group(0)

        lat = extract_attr(div_tag, "data-lat")
        lng = extract_attr(div_tag, "data-lng")
        img = extract_attr(div_tag, "data-img")
        name = extract_attr(div_tag, "data-name")
        link = extract_attr(div_tag, "data-link")
        status = extract_attr(div_tag, "data-status")

        if lat and lng and name:
            results.append(
                {
                    "lat": lat,
                    "lng": lng,
                    "img": img or "",
                    "name": name,
                    "link": link or "",
                    "status": status or "",
                }
            )

    return results


def extract_attr(tag_str, attr_name):
    """Estrae il valore di un attributo HTML da una stringa di tag."""
    pattern = re.compile(attr_name + r'="([^"]*)"')
    m = pattern.search(tag_str)
    return m.group(1) if m else None


def parse_single_hut(
    lat_str, lng_str, img_path, name_raw, link, status_raw, html_content
):
    """
    Costruisce un UnifiedShelter da una singola capanna.
    Cerca anche capacita' e localita' nel contenuto interno del card.
    """
    # Decodifica entita' HTML nel nome
    name = decode_html_entities(name_raw).strip()
    if not name:
        return None

    # Coordinate
    try:
        lat = float(lat_str)
        lng = float(lng_str)
    except (ValueError, TypeError):
        return None

    # Validazione coordinate (Ticino/Moesano: ~45.8-46.7 lat, 8.0-9.5 lng)
    if not (45.5 <= lat <= 47.0 and 7.5 <= lng <= 10.0):
        print(f"    WARN: coordinate fuori range per {name}: {lat}, {lng}")

    # Source ID dal link (es. "/it/capanne/capanna-tremorgio" -> "capanna-tremorgio")
    source_id = (
        link.rstrip("/").split("/")[-1] if link else name.lower().replace(" ", "-")
    )

    # Tipo: "Custodita" -> rifugio, "Non custodita" -> bivacco
    status_clean = decode_html_entities(status_raw).strip()
    shelter_type = normalize_type(status_clean, name)

    # Immagine
    image_urls = []
    if img_path:
        # Le immagini sono URL relativi, prepend base URL
        img_url = BASE_URL + img_path if img_path.startswith("/") else img_path
        image_urls.append(img_url)

    # Status per il campo status del modello
    status = None  # Le capanne in lista sono tutte attive

    # Cerca capacita' e localita' nel contenuto HTML vicino a questa card
    capacity = extract_capacity_for_hut(html_content, name_raw)
    region, valley = extract_location_for_hut(html_content, name_raw)

    # Website: link alla pagina di dettaglio su capanneti.ch
    website = BASE_URL + link if link and link.startswith("/") else None

    return UnifiedShelter(
        source="capanneti.ch",
        source_id=source_id,
        name=name,
        lat=lat,
        lng=lng,
        shelter_type=shelter_type,
        country="CH",
        capacity=capacity,
        region=region or "Ticino",
        valley=valley,
        website=website,
        image_urls=image_urls,
        operator="CAS" if status_clean == "Custodita" else None,
    )


def extract_capacity_for_hut(html_content, name_raw):
    """
    Cerca la capacita' (posti letto) nel contenuto HTML vicino alla card.
    Pattern: testo "X posti" in un div post-05__location dopo il nome.
    """
    # Cerca un blocco di testo vicino al nome della capanna con "N posti"
    # Usiamo il nome come ancora per trovare il contesto giusto
    escaped_name = re.escape(name_raw)
    # Cerchiamo in un blocco di ~2000 caratteri dopo il nome
    name_pos = html_content.find(name_raw)
    if name_pos < 0:
        return None

    # Cerca nei 2000 caratteri successivi al nome
    context = html_content[name_pos : name_pos + 2000]

    # Pattern: "N posti" dove N e' un numero
    posti_match = re.search(r"(\d+)\s+posti", context)
    if posti_match:
        try:
            return int(posti_match.group(1))
        except ValueError:
            pass

    return None


def extract_location_for_hut(html_content, name_raw):
    """
    Cerca la localita' (regione, valle) nel contenuto HTML vicino alla card.
    Pattern: "Regione , Valle" in un div post-05__location.
    """
    name_pos = html_content.find(name_raw)
    if name_pos < 0:
        return None, None

    # Cerca nei 2000 caratteri successivi al nome
    context = html_content[name_pos : name_pos + 2000]

    # Pattern: contenuto di post-05__location che contiene una virgola
    # (il primo post-05__location con posti e' gia' gestito sopra)
    location_pattern = re.compile(
        r'class="post-05__location"[^>]*>\s*([^<]+,[^<]+)\s*<', re.DOTALL
    )
    loc_match = location_pattern.search(context)
    if loc_match:
        parts = loc_match.group(1).strip().split(",")
        if len(parts) >= 2:
            region = decode_html_entities(parts[0].strip())
            valley = decode_html_entities(parts[1].strip())
            return region, valley

    return None, None


# ── Validazione ─────────────────────────────────────────────────────


def validate_shelters(shelters):
    """Filtra shelter con dati validi."""
    valid = []
    skipped = 0

    for s in shelters:
        # Coordinate valide per il Ticino/Moesano
        if not (45.0 <= s.lat <= 47.5 and 7.0 <= s.lng <= 10.5):
            print(
                f"  WARN: {s.name} scartato, coordinate fuori range: {s.lat}, {s.lng}"
            )
            skipped += 1
            continue

        # Nome non vuoto
        if not s.name or not s.name.strip():
            skipped += 1
            continue

        valid.append(s)

    if skipped > 0:
        print(f"  Scartati {skipped} per dati invalidi")

    return valid


# ── Main ────────────────────────────────────────────────────────────


def main():
    print("=" * 60)
    print("IMPORT CAPANNETI.CH — Capanne del Ticino e Moesano")
    print("=" * 60)

    # 1. Fetch pagina HTML
    print("\n1. Download pagina capanneti.ch...")
    html_content = fetch_page()
    print(f"   Ricevuti {len(html_content)} bytes di HTML")

    # 2. Parsing
    print("\n2. Parsing capanne dalla pagina HTML...")
    shelters = parse_huts_from_html(html_content)
    print(f"   Estratte: {shelters.__len__()} capanne")

    # 3. Validazione
    print("\n3. Validazione...")
    shelters = validate_shelters(shelters)
    print(f"   Valide: {len(shelters)} capanne")

    # 4. Distribuzione per tipo
    type_counts = {}
    for s in shelters:
        type_counts[s.shelter_type] = type_counts.get(s.shelter_type, 0) + 1
    print("\n4. Distribuzione per tipo:")
    for t, count in sorted(type_counts.items()):
        print(f"   {t}: {count}")

    # 5. Salvataggio
    print(f"\n5. Salvataggio in scripts/data/{OUTPUT_FILE}...")
    filepath = save_intermediate(shelters, OUTPUT_FILE)
    print(f"   Salvato: {filepath}")

    # 6. Statistiche finali
    print_stats("Capanneti.ch", shelters)

    print(f"\n{'=' * 60}")
    print("IMPORT CAPANNETI.CH completato!")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    main()
