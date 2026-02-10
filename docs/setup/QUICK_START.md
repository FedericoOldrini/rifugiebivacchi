# Quick Start Guide - Rifugi e Bivacchi

Guida rapida per iniziare a utilizzare l'app.

## Avvio Rapido (senza Google Maps)

Se vuoi testare subito l'app senza configurare Google Maps:

```bash
flutter run
```

L'app si avvierà e potrai usare:
- ✅ Tab "Lista" con ricerca funzionante
- ✅ Visualizzazione dettagli rifugi
- ⚠️ La tab "Mappa" mostrerà errori (necessita API Key)

## Avvio Completo (con Google Maps)

1. Segui le istruzioni in [../setup/GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) per configurare la API Key
2. Esegui l'app:

```bash
flutter run
```

## Test su Dispositivi Specifici

### Android
```bash
flutter run -d android
```

### iOS (richiede macOS)
```bash
flutter run -d ios
```

### Web (la mappa potrebbe non funzionare perfettamente)
```bash
flutter run -d chrome
```

## Comandi Utili

### Analisi del codice
```bash
flutter analyze
```

### Formattazione del codice
```bash
flutter format lib/
```

### Pulizia cache
```bash
flutter clean
flutter pub get
```

### Build Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS (richiede macOS e certificato sviluppatore):**
```bash
flutter build ios --release
```

## Struttura dell'App

```
🏠 Home (con 2 tabs)
├── 📝 Lista Rifugi
│   ├── Ricerca per nome
│   └── Click → Dettaglio
└── 🗺️ Mappa
    ├── Marker dei rifugi
    └── Click marker → Dettaglio

📄 Dettaglio Rifugio
├── Informazioni complete
├── Contatti (telefono, email, web)
└── Pulsante "Apri in Google Maps"

⚙️ Settings (dal menu)
├── Info app
├── Privacy
└── Link a Donazioni

💝 Donazioni
└── Opzioni di supporto
```

## Troubleshooting

### La mappa non si carica
- Verifica di aver configurato correttamente la Google Maps API Key
- Controlla che le API siano abilitate nella Google Cloud Console

### Errori di permessi su Android
- Verifica che i permessi siano configurati in `AndroidManifest.xml`
- Prova a reinstallare l'app

### Errori di permessi su iOS
- Verifica che le descrizioni dei permessi siano in `Info.plist`
- Prova a reinstallare l'app

### L'app non compila
```bash
flutter clean
flutter pub get
flutter run
```

## Prossimi Passi

1. Testa la funzionalità di ricerca nella lista
2. Esplora i dettagli di alcuni rifugi
3. Configura Google Maps per vedere la mappa
4. Personalizza i dati in `lib/data/rifugi_data.dart`

---

Per documentazione completa, vedi [README.md](README.md)
