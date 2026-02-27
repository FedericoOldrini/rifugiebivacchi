# Makefile per Screenshot Tools - Rifugi e Bivacchi
# 
# Comandi disponibili:
#   make screenshots-auto    - Genera screenshot automaticamente con Flutter Driver
#   make screenshots-manual  - Genera screenshot manualmente (interattivo)
#   make overlays            - Aggiungi overlay agli screenshot esistenti
#   make screenshots-clean   - Pulisci screenshot generati
#   make help                - Mostra questo aiuto

PYTHON := python3
FLUTTER := flutter

# Directory
SCREENSHOT_DIR := screenshots
TEST_DRIVER_DIR := test_driver

.PHONY: help
help:
	@echo "🏔️  Screenshot Tools - Rifugi e Bivacchi"
	@echo ""
	@echo "Comandi disponibili:"
	@echo "  make screenshots-auto     - Genera screenshot automaticamente"
	@echo "  make screenshots-manual   - Genera screenshot manualmente"
	@echo "  make overlays             - Aggiungi overlay agli screenshot"
	@echo "  make screenshots-clean    - Pulisci screenshot generati"
	@echo "  make screenshots-setup    - Installa dipendenze Python"
	@echo "  make help                 - Mostra questo aiuto"
	@echo ""
	@echo "Esempi:"
	@echo "  make screenshots-auto     # Metodo automatico completo"
	@echo "  make screenshots-manual   # Metodo manuale con simulatore"

.PHONY: screenshots-setup
screenshots-setup:
	@echo "📦 Installazione dipendenze..."
	@pip3 install --upgrade Pillow || (echo "❌ Errore installazione Pillow"; exit 1)
	@echo "✅ Dipendenze installate!"

.PHONY: build-simulator
build-simulator:
	@echo "🔨 Compilazione app per simulatore..."
	@$(FLUTTER) build ios --simulator
	@echo "✅ Build completata!"

.PHONY: screenshots-auto
screenshots-auto: build-simulator
	@echo ""
	@echo "🎬 Avvio generazione screenshot automatici..."
	@echo ""
	@echo "📱 ISTRUZIONI:"
	@echo "  1. Apri un NUOVO terminale"
	@echo "  2. Esegui: flutter run --profile -t test_driver/app.dart"
	@echo "  3. Aspetta che l'app sia avviata"
	@echo "  4. Premi INVIO qui per continuare"
	@read -p ""
	@echo ""
	@echo "🚀 Esecuzione Flutter Driver..."
	@$(FLUTTER) drive --driver=test_driver/screenshot_test.dart || (echo "❌ Errore Flutter Driver"; exit 1)
	@echo ""
	@echo "🎨 Aggiunta overlay..."
	@$(PYTHON) tools/add_overlays.py --resize || (echo "❌ Errore overlay"; exit 1)
	@echo ""
	@echo "✅ Screenshot automatici completati!"
	@echo "📁 Cartella: $(SCREENSHOT_DIR)/final/"

.PHONY: screenshots-manual
screenshots-manual: build-simulator
	@echo "🎨 Avvio generazione screenshot manuali..."
	@$(PYTHON) tools/generate_screenshots.py || (echo "❌ Errore generazione"; exit 1)
	@echo "✅ Screenshot manuali completati!"

.PHONY: overlays
overlays:
	@echo "🎨 Aggiunta overlay agli screenshot..."
	@$(PYTHON) tools/add_overlays.py --input $(TEST_DRIVER_DIR)/screenshots --output $(SCREENSHOT_DIR)/final
	@echo "✅ Overlay aggiunti!"

.PHONY: overlays-resize
overlays-resize:
	@echo "🎨 Aggiunta overlay e ridimensionamento..."
	@$(PYTHON) tools/add_overlays.py --input $(TEST_DRIVER_DIR)/screenshots --output $(SCREENSHOT_DIR)/final --resize
	@echo "✅ Overlay e ridimensionamento completati!"

.PHONY: screenshots-clean
screenshots-clean:
	@echo "🧹 Pulizia screenshot..."
	@rm -rf $(SCREENSHOT_DIR)/raw
	@rm -rf $(SCREENSHOT_DIR)/with_overlay
	@rm -rf $(SCREENSHOT_DIR)/final
	@rm -rf $(TEST_DRIVER_DIR)/screenshots
	@echo "✅ Screenshot puliti!"

.PHONY: screenshots-check
screenshots-check:
	@echo "🔍 Verifica screenshot generati..."
	@if [ -d "$(SCREENSHOT_DIR)/final" ]; then \
		echo "📁 $(SCREENSHOT_DIR)/final:"; \
		find $(SCREENSHOT_DIR)/final -name "*.png" | wc -l | xargs echo "   Screenshot trovati:"; \
	else \
		echo "⚠️  Nessun screenshot finale trovato"; \
	fi
	@if [ -d "$(TEST_DRIVER_DIR)/screenshots" ]; then \
		echo "📁 $(TEST_DRIVER_DIR)/screenshots:"; \
		find $(TEST_DRIVER_DIR)/screenshots -name "*.png" | wc -l | xargs echo "   Screenshot trovati:"; \
	fi

# Alias comuni
.PHONY: auto
auto: screenshots-auto

.PHONY: manual
manual: screenshots-manual

.PHONY: clean
clean: screenshots-clean
