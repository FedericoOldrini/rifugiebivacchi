# Makefile per Screenshot & Store Tools - Rifugi e Bivacchi
#
# Comandi disponibili:
#   make screenshots          - Pipeline completa: cattura + overlay + resize
#   make screenshots-capture  - Solo cattura screenshot via integration_test
#   make overlays             - Solo overlay su screenshot raw esistenti
#   make upload-screenshots   - Upload screenshot su App Store Connect
#   make screenshots-clean    - Pulisci screenshot generati
#   make help                 - Mostra questo aiuto

PYTHON := python3
FLUTTER := flutter

# Directory
SCREENSHOT_DIR := screenshots
RAW_DIR := $(SCREENSHOT_DIR)/raw
FINAL_DIR := $(SCREENSHOT_DIR)/final

# Simulatore di default
DEVICE ?= iPhone 17 Pro Max

.PHONY: help
help:
	@echo "🏔️  Screenshot & Store Tools - Rifugi e Bivacchi"
	@echo ""
	@echo "Comandi disponibili:"
	@echo "  make screenshots          - Pipeline completa (cattura + overlay + resize)"
	@echo "  make screenshots-capture  - Solo cattura screenshot (integration_test)"
	@echo "  make overlays             - Solo overlay + resize su screenshot raw"
	@echo "  make upload-screenshots   - Upload screenshot su App Store Connect"
	@echo "  make screenshots-clean    - Pulisci tutti gli screenshot"
	@echo "  make screenshots-check    - Verifica screenshot generati"
	@echo "  make screenshots-setup    - Installa dipendenze Python"
	@echo "  make help                 - Mostra questo aiuto"
	@echo ""
	@echo "Opzioni:"
	@echo "  DEVICE='iPhone 15 Pro Max'  - Simulatore da usare (default: iPhone 15 Pro Max)"
	@echo ""
	@echo "Esempi:"
	@echo "  make screenshots                          # Pipeline completa"
	@echo "  make screenshots DEVICE='iPhone 16 Pro'   # Con simulatore specifico"
	@echo "  make overlays                             # Rigenera solo overlay"
	@echo "  make upload-screenshots                   # Upload su App Store Connect"

.PHONY: screenshots-setup
screenshots-setup:
	@echo "📦 Installazione dipendenze Python..."
	@pip3 install --upgrade Pillow PyJWT cryptography requests || (echo "❌ Errore installazione"; exit 1)
	@echo "✅ Dipendenze installate!"

.PHONY: screenshots
screenshots:
	@echo ""
	@echo "🏔️  Pipeline Screenshot Completa"
	@echo ""
	@$(PYTHON) tools/generate_screenshots.py --device "$(DEVICE)"

.PHONY: screenshots-capture
screenshots-capture:
	@echo ""
	@echo "📸 Cattura screenshot (solo integration_test, senza overlay)..."
	@echo ""
	@$(PYTHON) tools/generate_screenshots.py --device "$(DEVICE)" --no-overlay

.PHONY: overlays
overlays:
	@echo ""
	@echo "🎨 Overlay + resize su screenshot raw esistenti..."
	@echo ""
	@$(PYTHON) tools/generate_screenshots.py --skip-test

.PHONY: overlays-no-resize
overlays-no-resize:
	@echo ""
	@echo "🎨 Solo overlay (senza ridimensionamento)..."
	@echo ""
	@$(PYTHON) tools/add_overlays.py --input $(RAW_DIR) --output $(FINAL_DIR)

.PHONY: overlays-resize
overlays-resize:
	@echo ""
	@echo "🎨 Overlay + ridimensionamento per tutte le dimensioni App Store..."
	@echo ""
	@$(PYTHON) tools/add_overlays.py --input $(RAW_DIR) --output $(FINAL_DIR) --resize

.PHONY: upload-screenshots
upload-screenshots:
	@echo ""
	@echo "📤 Upload screenshot su App Store Connect..."
	@echo ""
	@$(PYTHON) tools/upload_screenshots.py

.PHONY: screenshots-clean
screenshots-clean:
	@echo "🧹 Pulizia screenshot..."
	@rm -rf $(SCREENSHOT_DIR)/raw
	@rm -rf $(SCREENSHOT_DIR)/final
	@echo "✅ Screenshot puliti!"

.PHONY: screenshots-check
screenshots-check:
	@echo "🔍 Verifica screenshot generati..."
	@echo ""
	@if [ -d "$(RAW_DIR)" ]; then \
		echo "📁 $(RAW_DIR):"; \
		find $(RAW_DIR) -name "*.png" | sort; \
		echo "   Totale: $$(find $(RAW_DIR) -name '*.png' | wc -l | tr -d ' ') screenshot"; \
		echo ""; \
	else \
		echo "⚠️  Nessun screenshot raw trovato ($(RAW_DIR))"; \
		echo ""; \
	fi
	@if [ -d "$(FINAL_DIR)" ]; then \
		echo "📁 $(FINAL_DIR):"; \
		for dir in $(FINAL_DIR)/*/; do \
			if [ -d "$$dir" ]; then \
				echo "   └── $$(basename $$dir)/ ($$(find $$dir -name '*.png' | wc -l | tr -d ' ') screenshot)"; \
			fi; \
		done; \
		echo "   Totale: $$(find $(FINAL_DIR) -name '*.png' | wc -l | tr -d ' ') screenshot finali"; \
	else \
		echo "⚠️  Nessun screenshot finale trovato ($(FINAL_DIR))"; \
	fi

# Alias
.PHONY: auto
auto: screenshots

.PHONY: clean
clean: screenshots-clean

.PHONY: check
check: screenshots-check

.PHONY: upload
upload: upload-screenshots
