# Rifugi e Bivacchi — Roadmap di Sviluppo

> Piano evolutivo dell'app, organizzato per priorità e rilascio.
> Ultimo aggiornamento: febbraio 2026

---

## Legenda

| Simbolo | Significato |
|---------|-------------|
| 🔴 | Alta priorità — impatto diretto su UX o review Apple/Google |
| 🟡 | Media priorità — migliora significativamente l'esperienza |
| 🟢 | Bassa priorità — nice-to-have, espansioni future |
| ✅ | Completato |
| 🔲 | Da fare |
| 🚧 | In corso |

---

## v1.1 — Polish & Filtri (prossimo rilascio)

Obiettivo: correggere il debito tecnico della v1.0 e aggiungere le feature più richieste.

### 🔴 Filtri avanzati
- 🔲 Filtro per **tipo**: rifugio, bivacco, malga (checkbox/chip)
- 🔲 Filtro per **regione/provincia** (dropdown o multi-select)
- 🔲 Filtro per **range di altitudine** (slider min-max)
- 🔲 Filtro per **servizi disponibili**: Wi-Fi, ristorante, docce, acqua calda, POS, defibrillatore
- 🔲 Filtro per **accessibilità**: accesso disabili, famiglie, auto, MTB, animali
- 🔲 Filtro per **posti letto** (min)
- 🔲 UI: bottom sheet o pagina filtri dedicata con chip attivi nella barra di ricerca
- 🔲 Persistenza filtri con `SharedPreferences`
- **File coinvolti**: `filtro_provider.dart` (espandere), `rifugi_provider.dart`, `lista_rifugi_screen.dart`, `rifugi_service.dart` (query SQLite avanzate)

### 🔴 Ordinamento lista
- 🔲 Ordinamento per **distanza** (già default), **altitudine**, **nome A-Z**, **posti letto**
- 🔲 UI: dropdown o segmented control nella barra di ricerca
- **File coinvolti**: `rifugi_provider.dart`, `lista_rifugi_screen.dart`

### 🔴 Migrazione UIScene (iOS)
- 🚧 Aggiornamento `AppDelegate.swift` con `FlutterImplicitEngineDelegate`
- 🚧 Aggiornamento `Info.plist` con `UIApplicationSceneManifest`
- 🔲 Verifica build iOS funzionante
- **Motivo**: obbligatorio per iOS post-26, warning attivo

### 🟡 Localizzazione completa
- 🔲 Estrarre tutte le stringhe hardcoded in `passaporto_screen.dart` verso ARB
- 🔲 Estrarre stringhe hardcoded in `weather.dart` (descrizioni meteo)
- 🔲 Estrarre stringhe hardcoded in `settings_screen.dart`
- 🔲 Completare traduzioni EN, DE, FR per tutte le nuove stringhe
- **File coinvolti**: `app_it.arb`, `app_en.arb`, `app_de.arb`, `app_fr.arb`, vari screen

### 🟡 Note e foto nei check-in
- 🔲 Aggiungere campo **nota** al UI del check-in (il modello `RifugioCheckin` ha già il campo `note`)
- 🔲 Aggiungere possibilità di **scattare/allegare una foto** al check-in (campo `fotoUrl` già nel modello)
- 🔲 Upload foto su Firebase Storage
- 🔲 Mostrare nota e foto nella vista passaporto e nella card di condivisione
- **File coinvolti**: `dettaglio_rifugio_screen.dart`, `passaporto_screen.dart`, `passaporto_provider.dart`, `passaporto_service.dart`, `share_checkin_card.dart`

### 🟡 Debito tecnico
- 🔲 Spezzare `dettaglio_rifugio_screen.dart` (~1300 righe) in widget separati: `_HeaderSection`, `_MapSection`, `_WeatherSection`, `_ServicesSection`, `_ContactsSection`, `_GallerySection`
- 🔲 Estrarre `_MountainPatternPainter` duplicato (in `share_checkin_card.dart` e `passaporto_screen.dart`) in widget condiviso
- 🔲 Leggere versione app da `package_info_plus` invece di hardcodare "1.0.0" in settings
- 🔲 Configurare `appStoreId` per `in_app_review` in `settings_screen.dart`
- 🔲 Aggiungere custom event tracking con Firebase Analytics (schermate viste, check-in, ricerche, donazioni)
- 🔲 Gestire il warning del submodule `site/` (`.gitignore` o `git submodule`)

---

## v1.2 — Esplorazione & Scoperta

Obiettivo: rendere l'app più utile per pianificare escursioni e scoprire nuovi rifugi.

### 🟡 Rifugi nelle vicinanze
- 🔲 Sezione "Rifugi vicini" nel dettaglio di ogni rifugio (calcolo distanza geodetica)
- 🔲 Card orizzontali scrollabili con distanza e dislivello
- 🔲 Filtro sulla mappa: "Mostra rifugi nel raggio di X km"

### 🟡 Esplorazione per zona
- 🔲 Schermata **"Esplora"** con regioni/gruppi montuosi come card illustrate
- 🔲 Tap su regione → lista filtrata per quella zona
- 🔲 Possibilità di esplorare per: Dolomiti, Monte Bianco, Gran Paradiso, Appennini, ecc.
- 🔲 Raggruppamento basato su campo `valley` o coordinate geografiche

### 🟡 Statistiche personali
- 🔲 Dashboard nel profilo: numero rifugi visitati, altitudine massima raggiunta, regioni coperte
- 🔲 Grafico visite nel tempo (mensile/annuale)
- 🔲 Badge/traguardi: "10 rifugi visitati", "Sopra i 3000m", "Tutte le regioni alpine"
- 🔲 Condivisione statistiche come immagine social
- **Dipendenze**: potrebbe servire `fl_chart` o simile per grafici

### 🟢 Gestione mappe offline
- 🔲 UI per selezionare e **scaricare regioni** di mappa offline (il caching FMTC è già integrato)
- 🔲 Mostrare spazio occupato per regione
- 🔲 Possibilità di cancellare cache per regione
- **File coinvolti**: `offline_map_screen.dart`, nuovo `offline_maps_manager_screen.dart`

---

## v1.3 — Social & Community

Obiettivo: aggiungere elementi social per aumentare engagement e retention.

### 🟡 Recensioni e valutazioni
- 🔲 Sistema di **valutazione** (1-5 stelle) per ogni rifugio
- 🔲 **Recensioni testuali** degli utenti
- 🔲 Voto medio e numero recensioni visibili nella card e nel dettaglio
- 🔲 Moderazione base (segnalazione contenuti inappropriati)
- **Backend**: nuova collection Firestore `rifugi/{id}/reviews`

### 🟡 Condivisione rifugio
- 🔲 Deep link per condividere un rifugio specifico (Universal Links iOS + App Links Android)
- 🔲 Anteprima social (Open Graph) per link condivisi su WhatsApp/Telegram/social
- 🔲 Bottone "Condividi rifugio" nel dettaglio (già c'è share check-in, manca share rifugio generico)
- **Dipendenze**: `firebase_dynamic_links` o custom URL scheme

### 🟢 Liste personalizzate
- 🔲 Creare **liste tematiche** di rifugi (es. "Weekend in Dolomiti", "Rifugi con ristorante")
- 🔲 Aggiungere/rimuovere rifugi dalle liste
- 🔲 Condividere liste con altri utenti
- **Backend**: nuova collection Firestore `users/{uid}/lists`

### 🟢 Foto della community
- 🔲 Permettere agli utenti di **caricare foto** dei rifugi
- 🔲 Galleria community nel dettaglio rifugio (separata dalle foto ufficiali)
- 🔲 Moderazione e segnalazione
- **Backend**: Firebase Storage + collection `rifugi/{id}/communityPhotos`

---

## v1.4 — Trekking & Percorsi

Obiettivo: trasformare l'app da semplice catalogo a strumento di pianificazione escursioni.

### 🟡 Itinerari
- 🔲 Implementare la sezione **"I miei itinerari"** (placeholder già presente in `profilo_screen.dart`)
- 🔲 Creare itinerari collegando più rifugi in sequenza
- 🔲 Visualizzare itinerario sulla mappa con linea di collegamento
- 🔲 Calcolo distanza totale e dislivello cumulativo
- 🔲 Condivisione itinerario

### 🟢 Import/Export GPX
- 🔲 Importare tracce GPX da file
- 🔲 Mostrare rifugi lungo un percorso GPX importato
- 🔲 Esportare posizione rifugi come waypoint GPX
- **Dipendenze**: `gpx` o `xml` package per parsing

### 🟢 Profilo altimetrico
- 🔲 Mostrare profilo altimetrico tra posizione utente e rifugio
- 🔲 Dati elevazione da API esterne (Open-Elevation o Mapbox)
- **Dipendenze**: `fl_chart` per rendering profilo

### 🟢 Tracciamento percorso live
- 🔲 Registrazione GPS del percorso durante un'escursione
- 🔲 Salvataggio locale della traccia
- 🔲 Statistiche percorso: distanza, dislivello, tempo
- **Dipendenze**: `geolocator` (già presente), `background_locator` o simile per tracking in background

---

## v2.0 — Espansione & Monetizzazione

Obiettivo: espandere l'app oltre i confini attuali e creare sostenibilità.

### 🟢 Dati ampliati
- 🔲 Aggiungere **periodi di apertura/chiusura** stagionali (il campo `status` esiste ma non è dettagliato)
- 🔲 Integrazione con **bollettino valanghe** (API AINEVA)
- 🔲 Condizioni sentiero in tempo reale (crowdsourced)
- 🔲 Link a webcam vicine

### 🟢 Copertura internazionale
- 🔲 Rifugi Austria (Alpenverein ÖAV)
- 🔲 Rifugi Svizzera (SAC)
- 🔲 Rifugi Francia (FFCAM)
- 🔲 Rifugi Germania (DAV)
- 🔲 Adattare modello dati per multi-paese

### 🟢 Widget iOS / Android
- 🔲 Widget "Rifugio del giorno" per home screen
- 🔲 Widget "Meteo rifugio preferito"
- **Dipendenze**: `home_widget` package

### 🟢 Apple Watch / Wear OS
- 🔲 Complicazione con rifugio più vicino
- 🔲 Navigazione base al rifugio dal polso

### 🟢 Notifiche push
- 🔲 Reminder per rifugi preferiti vicini (geofencing)
- 🔲 Notifica apertura stagionale di un rifugio preferito
- 🔲 Notifica meteo avverso per rifugi in lista
- **Dipendenze**: `firebase_messaging`, Cloud Functions

### 🟢 Monetizzazione avanzata
- 🔲 Versione **Premium** (subscription) con: mappe offline illimitate, niente pubblicità, filtri avanzati, export GPX
- 🔲 Oppure: mantenere tutto gratuito con solo donazioni (modello attuale)

---

## Backlog — Idee a lungo termine

| Idea | Note |
|------|------|
| Modalità escursione con schermo always-on | Utile in montagna, mostra bussola + distanza rifugio |
| Integrazione HealthKit/Google Fit | Registrare dislivello e calorie |
| AR (Realtà Aumentata) | Puntare fotocamera per vedere rifugi in direzione |
| Chatbot / AI assistant | "Consigliami un rifugio per famiglie in Trentino con ristorante" |
| Prenotazione diretta | Integrazione con sistemi di prenotazione rifugi (se disponibili) |
| Segnalazione problemi sentieri | Community-driven trail conditions |
| Integrazione Komoot/Strava | Import percorsi da altre piattaforme |
| Dark sky / osservazione stellare | Mappa inquinamento luminoso per bivacchi |

---

## Note tecniche trasversali

### Accessibilità (a11y)
- 🔲 Aggiungere `Semantics` labels a tutti i widget interattivi
- 🔲 Testare con VoiceOver (iOS) e TalkBack (Android)
- 🔲 Assicurare contrasto colori WCAG AA in entrambi i temi

### Performance
- 🔲 Lazy loading immagini nella lista (già `CachedNetworkImage`, verificare placeholder)
- 🔲 Paginazione lista rifugi per dataset grandi
- 🔲 Ottimizzare query SQLite con indici su campi filtro

### Testing
- 🔲 Unit test per providers e services
- 🔲 Widget test per schermate principali
- 🔲 Integration test per flussi critici (login → check-in → share)
- 🔲 Golden test per UI consistency

### CI/CD
- 🔲 GitHub Actions per build automatico su push
- 🔲 Fastlane per deploy automatico su TestFlight e Play Console
- 🔲 Distribuzione beta con Firebase App Distribution
