#!/usr/bin/env bash
#
# capture_screenshots.sh — Cattura screenshot dal simulatore iOS
#
# Lancia il test di integrazione Flutter e cattura gli screenshot
# del display del simulatore con `xcrun simctl io screenshot`
# quando il test segnala che una schermata è pronta.
#
# Il test Dart stampa marker "SCREENSHOT_READY:<nome>" quando una
# schermata è pronta per la cattura. Questo script monitora lo
# stdout e cattura immediatamente.
#
# Uso:
#   tools/capture_screenshots.sh [simulator-id] [output-dir]
#
# Parametri:
#   simulator-id  UDID del simulatore (default: primo booted)
#   output-dir    Directory output (default: screenshots/raw)
#
set -euo pipefail

SENTINEL="/tmp/.screenshot_mode"

# ── Cleanup garantito ───────────────────────────────────────────
cleanup() {
  rm -f "$SENTINEL"
  xcrun simctl status_bar "${SIMULATOR_ID:-}" clear 2>/dev/null || true
  echo "🧹 Cleanup completato."
}
trap cleanup EXIT

# ── Parametri ───────────────────────────────────────────────────
SIMULATOR_ID="${1:-}"
OUTPUT_DIR="${2:-screenshots/raw}"

if [ -z "$SIMULATOR_ID" ]; then
  # Trova il primo simulatore booted
  SIMULATOR_ID=$(xcrun simctl list devices booted -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d.get('state') == 'Booted':
            print(d['udid'])
            sys.exit(0)
sys.exit(1)
" 2>/dev/null) || {
    echo "❌ Nessun simulatore booted trovato. Avviarne uno con:"
    echo "   xcrun simctl boot <simulator-id>"
    exit 1
  }
fi

echo "📱 Simulatore: $SIMULATOR_ID"
echo "📁 Output dir: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ── Screenshot mode sentinel ────────────────────────────────────
# AppDelegate.swift controlla questo file: se presente, salta
# GMSServices.provideAPIKey() evitando il popup di localizzazione.
echo "🚫 Attivo screenshot mode (sentinel: $SENTINEL)"
touch "$SENTINEL"

# ── Grant permessi (tentativo — non funziona su tutti gli OS) ───
echo "🔑 Concedo permessi localizzazione..."
xcrun simctl privacy "$SIMULATOR_ID" grant location-always \
  it.federicooldrini.rifugiebivacchi 2>/dev/null || true

# ── Status bar pulita per screenshot ────────────────────────────
echo "📶 Configuro status bar pulita..."
xcrun simctl status_bar "$SIMULATOR_ID" override \
  --time "9:41" \
  --batteryState charged \
  --batteryLevel 100 \
  --cellularMode active \
  --cellularBars 4 \
  --wifiBars 3 \
  --operatorName "" 2>/dev/null || true

# ── Lancia il test e cattura screenshot ─────────────────────────
echo "🚀 Lancio test di integrazione..."
CAPTURED=0

# Esegue flutter test e processa l'output riga per riga
flutter test integration_test/screenshot_test.dart \
  -d "$SIMULATOR_ID" 2>&1 | while IFS= read -r line; do

  # Mostra l'output del test
  echo "$line"

  # Controlla se c'è un marker screenshot
  if [[ "$line" == *"SCREENSHOT_READY:"* ]]; then
    # Estrai il nome dello screenshot
    SCREENSHOT_NAME="${line##*SCREENSHOT_READY:}"
    # Rimuovi eventuali spazi/caratteri di controllo
    SCREENSHOT_NAME=$(echo "$SCREENSHOT_NAME" | tr -d '[:space:]')
    OUTPUT_PATH="$OUTPUT_DIR/${SCREENSHOT_NAME}.png"

    echo "📸 Cattura: $SCREENSHOT_NAME → $OUTPUT_PATH"
    xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT_PATH" 2>/dev/null

    if [ -f "$OUTPUT_PATH" ]; then
      SIZE=$(stat -f%z "$OUTPUT_PATH")
      echo "✅ Salvato: $OUTPUT_PATH ($SIZE bytes)"
      CAPTURED=$((CAPTURED + 1))
    else
      echo "❌ Errore cattura: $SCREENSHOT_NAME"
    fi
  fi

  # Fine del test
  if [[ "$line" == *"SCREENSHOT_DONE"* ]]; then
    echo ""
    echo "🏁 Test completato."
  fi
done

# ── Report ──────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
echo "📊 Screenshot catturati in: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"/*.png 2>/dev/null || echo "(nessun file)"
echo "═══════════════════════════════════════════════"
