# Rifugi e Bivacchi 🏔️

App Flutter multipiattaforma per visualizzare rifugi e bivacchi di montagna nelle Alpi italiane.

## 📱 Funzionalità

- **Lista cercabile**: Visualizza tutti i rifugi e bivacchi in una lista scrollabile con funzione di ricerca
- **Mappa interattiva**: Esplora i rifugi su una mappa Google Maps centrata sulla tua posizione
- **Dettagli completi**: Visualizza informazioni dettagliate su ogni rifugio (altitudine, posti letto, contatti)
- **Navigazione**: Apri direttamente Google Maps per ottenere indicazioni stradali
- **Contatti diretti**: Chiama, invia email o visita il sito web del rifugio con un tap
- **Tema montagna**: Design con colori ispirati alla natura alpina

## 🚀 Come iniziare

### Prerequisiti

- Flutter SDK (>= 3.10.7)
- Dart SDK
- Android Studio / Xcode per sviluppo mobile
- Google Maps API Key

### Installazione

1. Clona il repository:
```bash
git clone https://github.com/your-username/rifugi_bivacchi.git
cd rifugi_bivacchi
```

2. Installa le dipendenze:
```bash
flutter pub get
```

3. Configura la Google Maps API Key:

**Android**: Modifica `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="LA_TUA_API_KEY_QUI"/>
```

**iOS**: Modifica `ios/Runner/Info.plist`
```xml
<key>GMSApiKey</key>
<string>LA_TUA_API_KEY_QUI</string>
```

4. Esegui l'app:
```bash
flutter run
```

## 📦 Dipendenze principali

- `provider`: State management
- `google_maps_flutter`: Integrazione mappe Google
- `geolocator`: Geolocalizzazione
- `permission_handler`: Gestione permessi
- `url_launcher`: Apertura link esterni

## 🏗️ Struttura del progetto

```
lib/
├── data/
│   └── rifugi_data.dart          # Database locale rifugi
├── models/
│   └── rifugio.dart              # Modello dati Rifugio
├── providers/
│   └── rifugi_provider.dart      # State management
├── screens/
│   ├── home_screen.dart          # Schermata principale con tabs
│   ├── lista_rifugi_screen.dart  # Tab lista con ricerca
│   ├── mappa_rifugi_screen.dart  # Tab mappa
│   ├── dettaglio_rifugio_screen.dart  # Dettagli rifugio
│   ├── settings_screen.dart      # Impostazioni
│   └── donations_screen.dart     # Pagina donazioni
├── theme/
│   └── app_theme.dart            # Tema e colori app
├── widgets/
│   └── rifugio_card.dart         # Widget card rifugio
└── main.dart                     # Entry point
```

## 🗺️ Dati

L'app include 15 rifugi e bivacchi precaricati nelle seguenti zone:
- Alpi Occidentali (Gran Paradiso, Monte Bianco)
- Dolomiti (Tre Cime di Lavaredo, Lagazuoi)
- Monte Rosa
- Alpi Centrali e Orientali

## 📱 Permessi

L'app richiede i seguenti permessi:

### Android
- `ACCESS_FINE_LOCATION`: Posizione precisa per la mappa
- `ACCESS_COARSE_LOCATION`: Posizione approssimativa
- `INTERNET`: Caricamento mappe

### iOS
- `NSLocationWhenInUseUsageDescription`: Accesso alla posizione durante l'uso
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Accesso alla posizione

## 🎨 Tema

Colori ispirati alla montagna:
- Verde montagna (`#2D5016`)
- Verde foresta (`#4A7C3C`)
- Azzurro cielo (`#87CEEB`)
- Bianco neve (`#F8F9FA`)
- Grigio roccia (`#6C757D`)
- Arancio tramonto (`#FF8C42`)

## 🤝 Contribuire

I contributi sono benvenuti! Per favore:
1. Fai un fork del progetto
2. Crea un branch per la tua feature (`git checkout -b feature/AmazingFeature`)
3. Commit delle modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📄 Licenza

Questo progetto è rilasciato sotto licenza MIT.

## 👤 Autore

Creato con ❤️ per gli amanti della montagna

## 🙏 Ringraziamenti

- Dati dei rifugi dalle fonti pubbliche del CAI (Club Alpino Italiano)
- Icone da Material Design
- Google Maps Platform per le mappe

---

**Nota**: Questa è un'app dimostrativa. Per un uso in produzione, considera di:
- Implementare un backend per i dati dei rifugi
- Aggiungere autenticazione utente
- Implementare recensioni e rating
- Aggiungere foto dei rifugi
- Implementare notifiche meteo
