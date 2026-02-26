#!/usr/bin/env python3
"""
Upload Screenshots to App Store Connect - Rifugi e Bivacchi

Carica automaticamente gli screenshot generati su App Store Connect
usando l'App Store Connect API v3.

Requisiti:
- Python 3.7+
- PyJWT: pip3 install PyJWT cryptography requests
- API Key P8 file in ~/private_keys/AuthKey_M6WVD946N7.p8
- Screenshot generati in screenshots/final/

Uso:
    python3 tools/upload_screenshots.py
    python3 tools/upload_screenshots.py --version 1.0.0
    python3 tools/upload_screenshots.py --dry-run
"""

import sys
import time
import json
import hashlib
import argparse
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

try:
    import jwt
    import requests
except ImportError:
    missing = []
    try:
        import jwt
    except ImportError:
        missing.append("PyJWT")
    try:
        import requests
    except ImportError:
        missing.append("requests")
    print(f"❌ Pacchetti mancanti: {', '.join(missing)}")
    print(f"   Installa con: pip3 install PyJWT cryptography requests")
    sys.exit(1)

# ── Configurazione App Store Connect ──────────────────────────────────────────

ISSUER_ID = "d2d23ddf-c15d-44d4-9a56-705cbab0f2dc"
API_KEY_ID = "M6WVD946N7"
KEY_FILE = Path.home() / "private_keys" / f"AuthKey_{API_KEY_ID}.p8"

BUNDLE_ID = "it.federicooldrini.rifugiebivacchi"
BASE_URL = "https://api.appstoreconnect.apple.com/v1"

# Directory screenshot
PROJECT_ROOT = Path(__file__).parent.parent
FINAL_DIR = PROJECT_ROOT / "screenshots" / "final"

# Mapping dimensioni directory → displayType App Store Connect API
# Ref: https://developer.apple.com/documentation/appstoreconnectapi/screenshotdisplaytype
DISPLAY_TYPE_MAP = {
    "iPhone_6_9": "APP_IPHONE_69",
    "iPhone_6_7": "APP_IPHONE_67",
    "iPhone_6_5": "APP_IPHONE_65",
    "iPhone_5_5": "APP_IPHONE_55",
    "iPad_Pro_13": "APP_IPAD_PRO_3RD_GEN_129",
    "iPad_Pro_12_9": "APP_IPAD_PRO_129",
}

# Ordine degli screenshot (1-based position)
SCREENSHOT_ORDER = [
    "01_lista_rifugi",
    "02_mappa",
    "03_dettaglio_rifugio",
    "04_profilo",
    "05_passaporto",
]


# ── JWT Auth ──────────────────────────────────────────────────────────────────


def generate_token() -> str:
    """Genera JWT token per App Store Connect API"""
    if not KEY_FILE.exists():
        print(f"❌ API key non trovata: {KEY_FILE}")
        print(f"   Scaricala da App Store Connect → Users and Access → Keys")
        sys.exit(1)

    private_key = KEY_FILE.read_text()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20 minuti
        "aud": "appstoreconnect-v1",
    }

    headers = {
        "alg": "ES256",
        "kid": API_KEY_ID,
        "typ": "JWT",
    }

    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
    return token


def api_headers(token: str) -> Dict[str, str]:
    """Headers per le richieste API"""
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }


# ── API Helpers ───────────────────────────────────────────────────────────────


def api_get(token: str, path: str, params: Optional[Dict] = None) -> Dict:
    """GET request all'API"""
    url = f"{BASE_URL}/{path}" if not path.startswith("http") else path
    resp = requests.get(url, headers=api_headers(token), params=params)
    if resp.status_code != 200:
        print(f"   ❌ GET {path} → {resp.status_code}")
        print(f"      {resp.text[:500]}")
        return {}
    return resp.json()


def api_post(token: str, path: str, data: Dict) -> Optional[Dict]:
    """POST request all'API"""
    url = f"{BASE_URL}/{path}"
    resp = requests.post(url, headers=api_headers(token), json=data)
    if resp.status_code not in (200, 201):
        print(f"   ❌ POST {path} → {resp.status_code}")
        print(f"      {resp.text[:500]}")
        return None
    return resp.json()


def api_patch(token: str, path: str, data: Dict) -> Optional[Dict]:
    """PATCH request all'API"""
    url = f"{BASE_URL}/{path}"
    resp = requests.patch(url, headers=api_headers(token), json=data)
    if resp.status_code != 200:
        print(f"   ❌ PATCH {path} → {resp.status_code}")
        print(f"      {resp.text[:500]}")
        return None
    return resp.json()


def api_delete(token: str, path: str) -> bool:
    """DELETE request all'API"""
    url = f"{BASE_URL}/{path}"
    resp = requests.delete(url, headers=api_headers(token))
    if resp.status_code not in (200, 204):
        print(f"   ❌ DELETE {path} → {resp.status_code}")
        print(f"      {resp.text[:500]}")
        return False
    return True


# ── App Store Connect Flow ────────────────────────────────────────────────────


def find_app(token: str) -> Optional[str]:
    """Trova l'app per bundle ID e restituisce l'app ID"""
    data = api_get(token, "apps", {"filter[bundleId]": BUNDLE_ID})
    apps = data.get("data", [])
    if not apps:
        print(f"   ❌ App con bundle ID '{BUNDLE_ID}' non trovata")
        return None
    app_id = apps[0]["id"]
    app_name = apps[0]["attributes"].get("name", "N/A")
    print(f"   ✅ App trovata: {app_name} (ID: {app_id})")
    return app_id


def find_version(
    token: str, app_id: str, version_string: Optional[str] = None
) -> Optional[str]:
    """Trova la versione dell'app (editabile, in preparazione)"""
    params: Dict[str, Any] = {
        "filter[appStoreState]": "PREPARE_FOR_SUBMISSION,READY_FOR_REVIEW,WAITING_FOR_REVIEW,IN_REVIEW,REJECTED",
    }
    if version_string:
        params["filter[versionString]"] = version_string

    data = api_get(token, f"apps/{app_id}/appStoreVersions", params)
    versions = data.get("data", [])

    if not versions:
        # Prova anche DEVELOPER_REMOVED_FROM_SALE e altri stati
        params2: Dict[str, Any] = {}
        if version_string:
            params2["filter[versionString]"] = version_string
        data = api_get(token, f"apps/{app_id}/appStoreVersions", params2)
        versions = data.get("data", [])

    if not versions:
        print(f"   ❌ Nessuna versione editabile trovata")
        return None

    version = versions[0]
    v_string = version["attributes"].get("versionString", "?")
    v_state = version["attributes"].get("appStoreState", "?")
    print(f"   ✅ Versione trovata: {v_string} (stato: {v_state})")
    return version["id"]


def find_localizations(token: str, version_id: str) -> Dict[str, str]:
    """Trova le localizzazioni della versione (locale → ID)"""
    data = api_get(
        token,
        f"appStoreVersions/{version_id}/appStoreVersionLocalizations",
    )
    localizations = {}
    for loc in data.get("data", []):
        locale = loc["attributes"].get("locale", "")
        localizations[locale] = loc["id"]

    print(f"   ✅ Localizzazioni: {', '.join(localizations.keys())}")
    return localizations


def get_screenshot_sets(token: str, localization_id: str) -> Dict[str, str]:
    """Ottiene i screenshot set esistenti per una localizzazione (displayType → set ID)"""
    data = api_get(
        token,
        f"appStoreVersionLocalizations/{localization_id}/appScreenshotSets",
    )
    sets = {}
    for ss in data.get("data", []):
        display_type = ss["attributes"].get("screenshotDisplayType", "")
        sets[display_type] = ss["id"]
    return sets


def create_screenshot_set(
    token: str, localization_id: str, display_type: str
) -> Optional[str]:
    """Crea un nuovo screenshot set"""
    data = api_post(
        token,
        "appScreenshotSets",
        {
            "data": {
                "type": "appScreenshotSets",
                "attributes": {"screenshotDisplayType": display_type},
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {
                            "type": "appStoreVersionLocalizations",
                            "id": localization_id,
                        }
                    }
                },
            }
        },
    )
    if data:
        return data["data"]["id"]
    return None


def get_existing_screenshots(token: str, set_id: str) -> List[str]:
    """Ottiene gli screenshot esistenti in un set (restituisce lista di ID)"""
    data = api_get(token, f"appScreenshotSets/{set_id}/appScreenshots")
    return [s["id"] for s in data.get("data", [])]


def delete_screenshot(token: str, screenshot_id: str) -> bool:
    """Elimina un singolo screenshot"""
    return api_delete(token, f"appScreenshots/{screenshot_id}")


def reserve_screenshot(
    token: str, set_id: str, filename: str, file_size: int
) -> Optional[Dict]:
    """Riserva uno slot per upload screenshot"""
    data = api_post(
        token,
        "appScreenshots",
        {
            "data": {
                "type": "appScreenshots",
                "attributes": {
                    "fileName": filename,
                    "fileSize": file_size,
                },
                "relationships": {
                    "appScreenshotSet": {
                        "data": {
                            "type": "appScreenshotSets",
                            "id": set_id,
                        }
                    }
                },
            }
        },
    )
    if data:
        return data["data"]
    return None


def upload_screenshot_asset(upload_operations: List[Dict], file_path: Path) -> bool:
    """Esegue l'upload effettivo del file seguendo le upload operations"""
    file_data = file_path.read_bytes()

    for op in upload_operations:
        url = op["url"]
        offset = op.get("offset", 0)
        length = op["length"]
        method = op.get("method", "PUT")
        request_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}

        chunk = file_data[offset : offset + length]

        if method.upper() == "PUT":
            resp = requests.put(url, headers=request_headers, data=chunk)
        else:
            resp = requests.post(url, headers=request_headers, data=chunk)

        if resp.status_code not in (200, 201):
            print(f"      ❌ Upload chunk fallito: {resp.status_code}")
            return False

    return True


def commit_screenshot(token: str, screenshot_id: str, checksum: str) -> bool:
    """Conferma l'upload dello screenshot"""
    data = api_patch(
        token,
        f"appScreenshots/{screenshot_id}",
        {
            "data": {
                "type": "appScreenshots",
                "id": screenshot_id,
                "attributes": {
                    "sourceFileChecksum": checksum,
                    "uploaded": True,
                },
            }
        },
    )
    return data is not None


def upload_single_screenshot(token: str, set_id: str, file_path: Path) -> bool:
    """Upload completo di un singolo screenshot: reserve → upload → commit"""
    filename = file_path.name
    file_size = file_path.stat().st_size

    # Calcola checksum MD5
    md5 = hashlib.md5(file_path.read_bytes()).hexdigest()

    # 1. Reserve
    reservation = reserve_screenshot(token, set_id, filename, file_size)
    if not reservation:
        return False

    screenshot_id = reservation["id"]
    upload_ops = reservation["attributes"].get("uploadOperations", [])

    if not upload_ops:
        print(f"      ⚠️  Nessuna upload operation ricevuta")
        # Potrebbe essere già caricato, proviamo a committare
        return commit_screenshot(token, screenshot_id, md5)

    # 2. Upload
    if not upload_screenshot_asset(upload_ops, file_path):
        return False

    # 3. Commit
    if not commit_screenshot(token, screenshot_id, md5):
        return False

    return True


# ── Main Flow ─────────────────────────────────────────────────────────────────


def upload_screenshots(
    version: Optional[str] = None,
    locale: str = "it-IT",
    dry_run: bool = False,
    clean: bool = False,
):
    """Flusso principale di upload screenshot"""

    print(f"\n{'=' * 70}")
    print(f"🏔️  Upload Screenshot - App Store Connect")
    print(f"{'=' * 70}\n")

    # Verifica screenshot disponibili
    if not FINAL_DIR.exists():
        print(f"❌ Directory screenshot non trovata: {FINAL_DIR}")
        print(f"   Esegui prima: make screenshots")
        sys.exit(1)

    # Conta screenshot per dimensione
    size_dirs = [d for d in FINAL_DIR.iterdir() if d.is_dir()]
    if not size_dirs:
        print(f"❌ Nessuna sotto-directory trovata in {FINAL_DIR}")
        sys.exit(1)

    for sd in sorted(size_dirs):
        count = len(list(sd.glob("*.png")))
        display_type = DISPLAY_TYPE_MAP.get(sd.name, "???")
        print(f"   📁 {sd.name}/ → {display_type} ({count} screenshot)")

    if dry_run:
        print(f"\n🔍 DRY RUN - nessun upload effettuato")
        return

    # Genera token
    print(f"\n🔑 Autenticazione...")
    token = generate_token()
    print(f"   ✅ Token JWT generato")

    # Trova app
    print(f"\n🔍 Ricerca app...")
    app_id = find_app(token)
    if not app_id:
        sys.exit(1)

    # Trova versione
    print(f"\n🔍 Ricerca versione...")
    version_id = find_version(token, app_id, version)
    if not version_id:
        sys.exit(1)

    # Trova localizzazioni
    print(f"\n🌍 Localizzazioni...")
    localizations = find_localizations(token, version_id)

    if locale not in localizations:
        print(f"   ❌ Locale '{locale}' non trovato")
        print(f"   Disponibili: {', '.join(localizations.keys())}")
        sys.exit(1)

    localization_id = localizations[locale]
    print(f"   🎯 Locale target: {locale} (ID: {localization_id})")

    # Ottieni/crea screenshot sets
    print(f"\n📸 Preparazione screenshot sets...")
    existing_sets = get_screenshot_sets(token, localization_id)

    total_uploaded = 0

    for size_dir_name, display_type in DISPLAY_TYPE_MAP.items():
        size_dir = FINAL_DIR / size_dir_name
        if not size_dir.exists():
            print(f"\n   ⚠️  Cartella {size_dir_name}/ non trovata, skip")
            continue

        screenshots = sorted(size_dir.glob("*.png"))
        if not screenshots:
            print(f"\n   ⚠️  Nessun screenshot in {size_dir_name}/, skip")
            continue

        print(f"\n   📱 {display_type} ({size_dir_name})")

        # Trova o crea screenshot set
        if display_type in existing_sets:
            set_id = existing_sets[display_type]
            print(f"      Set esistente: {set_id}")

            # Pulisci screenshot esistenti se richiesto
            if clean:
                old_screenshots = get_existing_screenshots(token, set_id)
                if old_screenshots:
                    print(
                        f"      🧹 Rimozione {len(old_screenshots)} screenshot esistenti..."
                    )
                    for old_id in old_screenshots:
                        delete_screenshot(token, old_id)
                    time.sleep(1)
        else:
            set_id = create_screenshot_set(token, localization_id, display_type)
            if not set_id:
                print(f"      ❌ Impossibile creare screenshot set")
                continue
            print(f"      Nuovo set creato: {set_id}")

        # Upload screenshot
        for i, ss_path in enumerate(screenshots, 1):
            print(f"      📤 [{i}/{len(screenshots)}] {ss_path.name}...", end=" ")
            if upload_single_screenshot(token, set_id, ss_path):
                print("✅")
                total_uploaded += 1
            else:
                print("❌")

            # Rate limiting gentile
            time.sleep(0.5)

    # Riepilogo
    print(f"\n{'=' * 70}")
    print(f"✅ Upload completato!")
    print(f"   Screenshot caricati: {total_uploaded}")
    print(f"   Locale: {locale}")
    print(f"\n📱 Verifica su App Store Connect:")
    print(f"   https://appstoreconnect.apple.com")
    print(f"{'=' * 70}\n")


def main():
    parser = argparse.ArgumentParser(
        description="Upload screenshot su App Store Connect"
    )
    parser.add_argument(
        "--version",
        type=str,
        default=None,
        help="Versione specifica (es. 1.0.0). Default: prima versione editabile",
    )
    parser.add_argument(
        "--locale",
        type=str,
        default="it-IT",
        help="Locale per gli screenshot (default: it-IT)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Mostra cosa verrebbe fatto senza caricare",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Rimuovi screenshot esistenti prima di caricare",
    )
    args = parser.parse_args()

    upload_screenshots(
        version=args.version,
        locale=args.locale,
        dry_run=args.dry_run,
        clean=args.clean,
    )


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
