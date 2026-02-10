# 🚀 Quick Start - Screenshot per App Store

Guida veloce per generare screenshot professionali in 5 minuti.

## ⚡ Setup Rapido (una volta sola)

```bash
# 1. Installa dipendenze Python
pip3 install Pillow

# 2. Verifica installazione
python3 -c "from PIL import Image; print('✅ OK')"
```

---

## 📸 Metodo Veloce (Consigliato)

### Opzione A: Screenshot Automatici

```bash
# 1. Compila app per simulatore
flutter build ios --simulator

# 2. Terminal 1: Avvia app con driver
flutter run --profile -t test_driver/app.dart

# 3. Terminal 2: Cattura screenshot
flutter drive --driver=test_driver/screenshot_test.dart

# 4. Aggiungi overlay e ridimensiona
python3 tools/add_overlays.py --resize
```

✅ Screenshot pronti in: `screenshots/final/`

### Opzione B: Screenshot Manuali (più controllo)

```bash
# 1. Esegui script interattivo
python3 tools/generate_screenshots.py

# 2. Segui le istruzioni a schermo
# Lo script fa tutto automaticamente!
```

✅ Screenshot pronti in: `screenshots/final/`

---

## 🎯 Con Makefile (ancora più veloce!)

```bash
# Setup (una volta)
make screenshots-setup

# Genera screenshot automatici
make screenshots-auto

# Oppure manuali
make screenshots-manual

# Pulisci tutto
make screenshots-clean
```

---

## 📤 Carica su App Store

1. Vai su [App Store Connect](https://appstoreconnect.apple.com)
2. App → App Store → Screenshot
3. Carica da `screenshots/final/`:
   - `iPhone_6_7/` → iPhone 6.7"
   - `iPhone_6_5/` → iPhone 6.5"
   - `iPad_Pro_12_9/` → iPad Pro

---

## 🆘 Problemi?

### "Pillow not found"
```bash
pip3 install Pillow
```

### "App not found"
```bash
flutter build ios --simulator
```

### "Simulatore non avvia"
- Apri Xcode
- Settings → Platforms → Scarica iOS Simulator

---

## 📖 Documentazione Completa

Vedi `docs/screenshots/README.md` per:
- Personalizzazione testi e colori
- Aggiungere nuovi screenshot
- Troubleshooting dettagliato
- Best practices

---

**Fatto! 🎉**

I tuoi screenshot sono pronti per App Store!
