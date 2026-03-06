#!/usr/bin/env bash
#
# capture_screenshots.sh — Cattura screenshot App Store da simulatori iOS
#
# Lancia il test di integrazione Flutter su uno o più simulatori iOS e cattura
# gli screenshot del display con `xcrun simctl io screenshot` quando il test
# segnala che una schermata è pronta (marker SCREENSHOT_READY:<nome>).
#
# Modalità:
#   1. Single device (default): cattura su un simulatore specifico o il primo booted
#   2. Multi-device (--all): cattura su tutti i simulatori necessari per l'App Store
#
# Uso:
#   tools/capture_screenshots.sh                     # Single: primo simulatore booted
#   tools/capture_screenshots.sh <simulator-id>      # Single: simulatore specifico
#   tools/capture_screenshots.sh --all               # Multi: tutti i simulatori App Store
#   tools/capture_screenshots.sh --all --overlay      # Multi + genera overlay finali
#
# Output:
#   screenshots/raw/<device_name>/<screenshot>.png   (multi-device)
#   screenshots/raw/<screenshot>.png                  (single device)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

SENTINEL="/tmp/.screenshot_mode"
RAW_DIR="screenshots/raw"

# ── Simulatori per App Store ────────────────────────────────────
# Ogni entry: <nome_output>|<nome_simulatore>
# I nomi output corrispondono alle chiavi in generate_screenshots.py
# iPhone_5_5 e iPad_Pro_12_9 vengono generati per resize, non servono simulatori dedicati
SIMULATORS=(
  "iPhone_6_9|iPhone 17 Pro Max"
  "iPhone_6_7|iPhone 17 Pro"
  "iPhone_6_5|iPhone 16e"
  "iPad_Pro_13|iPad Pro 13-inch (M5)"
)

# ── Parsing argomenti ───────────────────────────────────────────
MODE="single"
RUN_OVERLAY=false
SINGLE_SIMULATOR_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      MODE="multi"
      shift
      ;;
    --overlay)
      RUN_OVERLAY=true
      shift
      ;;
    --help|-h)
      echo "Uso: $0 [--all] [--overlay] [simulator-id]"
      echo ""
      echo "  --all       Cattura su tutti i simulatori App Store (4 device)"
      echo "  --overlay   Dopo la cattura, genera screenshot finali con overlay"
      echo "  <uuid>      UDID di un singolo simulatore (modalità single)"
      echo ""
      echo "Simulatori configurati per --all:"
      for sim in "${SIMULATORS[@]}"; do
        IFS='|' read -r out_name sim_name <<< "$sim"
        echo "  $out_name → $sim_name"
      done
      exit 0
      ;;
    *)
      SINGLE_SIMULATOR_ID="$1"
      shift
      ;;
  esac
done

# ── Cleanup garantito ───────────────────────────────────────────
BOOTED_BY_US=()
cleanup() {
  rm -f "$SENTINEL"
  # Ripristina status bar e chiudi i simulatori che abbiamo avviato noi
  for sim_id in "${BOOTED_BY_US[@]+"${BOOTED_BY_US[@]}"}"; do
    xcrun simctl status_bar "$sim_id" clear 2>/dev/null || true
    echo "🔌 Shutdown simulatore: $sim_id"
    xcrun simctl shutdown "$sim_id" 2>/dev/null || true
  done
  # Ripristina status bar del simulatore single mode (se diverso)
  if [[ -n "${CURRENT_SIM_ID:-}" ]]; then
    xcrun simctl status_bar "$CURRENT_SIM_ID" clear 2>/dev/null || true
  fi
  echo "🧹 Cleanup completato."
}
trap cleanup EXIT

# ── Helper: trova UDID di un simulatore per nome ────────────────
find_simulator_udid() {
  local name="$1"
  xcrun simctl list devices available -j | python3 -c "
import json, sys
name = sys.argv[1]
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d.get('name') == name and d.get('isAvailable', False):
            print(d['udid'])
            sys.exit(0)
print('', end='')
sys.exit(1)
" "$name" 2>/dev/null
}

# ── Helper: controlla se un simulatore è booted ─────────────────
is_booted() {
  local sim_id="$1"
  xcrun simctl list devices -j | python3 -c "
import json, sys
target = sys.argv[1]
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d.get('udid') == target and d.get('state') == 'Booted':
            sys.exit(0)
sys.exit(1)
" "$sim_id" 2>/dev/null
}

# ── Helper: boot simulatore e attendi che sia pronto ─────────────
boot_simulator() {
  local sim_id="$1"
  local sim_name="$2"

  if is_booted "$sim_id"; then
    echo "   ✓ $sim_name già booted"
    return 0
  fi

  echo "   ⏳ Boot $sim_name..."
  xcrun simctl boot "$sim_id"
  BOOTED_BY_US+=("$sim_id")

  # Attendi che il simulatore sia effettivamente pronto
  local max_wait=60
  local waited=0
  while ! is_booted "$sim_id"; do
    sleep 1
    waited=$((waited + 1))
    if [ $waited -ge $max_wait ]; then
      echo "   ❌ Timeout in attesa del boot di $sim_name"
      return 1
    fi
  done

  # Attendi ancora un po' per il boot completo di SpringBoard
  sleep 5
  echo "   ✓ $sim_name booted in ${waited}s"
}

# ── Helper: configura status bar pulita ──────────────────────────
configure_status_bar() {
  local sim_id="$1"
  xcrun simctl status_bar "$sim_id" override \
    --time "9:41" \
    --batteryState charged \
    --batteryLevel 100 \
    --cellularMode active \
    --cellularBars 4 \
    --wifiBars 3 \
    --operatorName "" 2>/dev/null || true
}

# ── Helper: concedi permessi localizzazione ──────────────────────
grant_permissions() {
  local sim_id="$1"
  xcrun simctl privacy "$sim_id" grant location-always \
    it.federicooldrini.rifugiebivacchi 2>/dev/null || true
}

# ── Core: cattura screenshot su un singolo simulatore ────────────
# Parametri: $1=simulator_id, $2=output_dir
# Ritorna 0 se almeno 1 screenshot catturato, 1 altrimenti
capture_on_simulator() {
  local sim_id="$1"
  local output_dir="$2"

  mkdir -p "$output_dir"
  CURRENT_SIM_ID="$sim_id"

  grant_permissions "$sim_id"
  configure_status_bar "$sim_id"

  echo "   🚀 Lancio test di integrazione..."

  # Disabilita pipefail temporaneamente: flutter test può uscire con codice
  # non-zero anche se gli screenshot sono stati catturati correttamente
  # (es. timeout, cleanup, etc.)
  set +o pipefail

  flutter test integration_test/screenshot_test.dart \
    -d "$sim_id" 2>&1 | while IFS= read -r line; do

    # Mostra l'output del test (indentato)
    echo "      $line"

    # Controlla se c'è un marker screenshot
    if [[ "$line" == *"SCREENSHOT_READY:"* ]]; then
      SCREENSHOT_NAME="${line##*SCREENSHOT_READY:}"
      SCREENSHOT_NAME=$(echo "$SCREENSHOT_NAME" | tr -d '[:space:]')
      OUTPUT_PATH="$output_dir/${SCREENSHOT_NAME}.png"

      echo "   📸 Cattura: $SCREENSHOT_NAME"
      xcrun simctl io "$sim_id" screenshot "$OUTPUT_PATH" 2>/dev/null

      if [ -f "$OUTPUT_PATH" ]; then
        SIZE=$(stat -f%z "$OUTPUT_PATH")
        echo "   ✅ $SCREENSHOT_NAME ($SIZE bytes)"
      else
        echo "   ❌ Errore cattura: $SCREENSHOT_NAME"
      fi
    fi

    if [[ "$line" == *"SCREENSHOT_DONE"* ]]; then
      echo "   🏁 Test completato"
    fi
  done

  set -o pipefail

  # Verifica quanti screenshot sono stati effettivamente catturati
  local actual_count
  actual_count=$(find "$output_dir" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$actual_count" -ge 1 ]; then
    echo "   📊 $actual_count screenshot catturati in $output_dir"
    return 0
  else
    echo "   ⚠️  Nessuno screenshot catturato"
    return 1
  fi
}

# ═══════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🏔️  Screenshot Cattura — Rifugi e Bivacchi"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Attiva screenshot mode
touch "$SENTINEL"
echo "🚫 Screenshot mode attivo (sentinel: $SENTINEL)"
echo ""

if [ "$MODE" = "multi" ]; then
  # ── Multi-device mode ─────────────────────────────────────────
  echo "📱 Modalità: MULTI-DEVICE (${#SIMULATORS[@]} simulatori)"
  echo ""

  # Pulisci raw dir precedente (per-device)
  rm -rf "$RAW_DIR"

  TOTAL_CAPTURED=0
  DEVICE_COUNT=0

  for sim in "${SIMULATORS[@]}"; do
    IFS='|' read -r out_name sim_name <<< "$sim"

    DEVICE_COUNT=$((DEVICE_COUNT + 1))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 Device $DEVICE_COUNT/${#SIMULATORS[@]}: $sim_name → $out_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Trova UDID
    sim_udid=$(find_simulator_udid "$sim_name") || {
      echo "   ❌ Simulatore '$sim_name' non trovato. Saltato."
      echo ""
      continue
    }
    echo "   UDID: $sim_udid"

    # Boot
    boot_simulator "$sim_udid" "$sim_name" || {
      echo "   ❌ Boot fallito per $sim_name. Saltato."
      echo ""
      continue
    }

    # Cattura (può fallire senza bloccare gli altri device)
    local_output="$RAW_DIR/$out_name"
    capture_on_simulator "$sim_udid" "$local_output" || {
      echo "   ⚠️  Cattura fallita per $sim_name, continuo con il prossimo device"
    }

    # Conta screenshot catturati
    local_count=$(find "$local_output" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_CAPTURED=$((TOTAL_CAPTURED + local_count))
    echo "   📊 $out_name: $local_count screenshot"
    echo ""
  done

  # ── Report multi-device ───────────────────────────────────────
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "📊 RIEPILOGO CATTURA MULTI-DEVICE"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  for sim in "${SIMULATORS[@]}"; do
    IFS='|' read -r out_name sim_name <<< "$sim"
    local_dir="$RAW_DIR/$out_name"
    if [ -d "$local_dir" ]; then
      count=$(find "$local_dir" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
      echo "   $out_name: $count screenshot"
    else
      echo "   $out_name: ❌ nessuno"
    fi
  done
  echo ""
  echo "   Totale: $TOTAL_CAPTURED screenshot raw"
  echo ""

  if [ $TOTAL_CAPTURED -lt 20 ]; then
    echo "⚠️  Attenzione: meno screenshot del previsto (attesi 20 = 5 schermate × 4 device)"
  fi

else
  # ── Single-device mode ────────────────────────────────────────
  if [ -z "$SINGLE_SIMULATOR_ID" ]; then
    SINGLE_SIMULATOR_ID=$(xcrun simctl list devices booted -j | python3 -c "
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
      echo ""
      echo "Oppure usa --all per catturare su tutti i simulatori App Store."
      exit 1
    }
  fi

  echo "📱 Modalità: SINGLE DEVICE"
  echo "   UDID: $SINGLE_SIMULATOR_ID"
  echo ""

  capture_on_simulator "$SINGLE_SIMULATOR_ID" "$RAW_DIR"

  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "📊 Screenshot catturati in: $RAW_DIR"
  ls -la "$RAW_DIR"/*.png 2>/dev/null || echo "(nessun file)"
  echo "═══════════════════════════════════════════════════════════"
fi

# ── Overlay (opzionale) ─────────────────────────────────────────
if [ "$RUN_OVERLAY" = true ]; then
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "🎨 Generazione overlay..."
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  python3 tools/generate_screenshots.py --skip-test
fi

echo ""
echo "🎉 Fatto!"
