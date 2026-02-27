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

### 🔴 Ridurre visibilità card donazioni nella lista
- ✅ Rimosso gradiente rosa/viola e sostituito con sfondo `surfaceContainerLow` (si fonde con il background)
- ✅ Rimosso container icona con ombra, sostituito con icona outline discreta (`favorite_border`)
- ✅ Rimossa seconda riga di testo (`supportDevelopment`), tenuto solo il messaggio principale
- ✅ Tutti i colori ora usano il `colorScheme` del tema (funziona in light e dark mode)
- ✅ Elevazione rimossa, bordo sottile e tenue
- **File modificato**: `lista_rifugi_screen.dart`

### 🔴 Audit colori e tema scuro
- ✅ Revisione **completa di tutti gli screen** in dark mode: verificato contrasto testi, icone, bordi, sfondi e divisori
- ✅ Sostituiti colori hardcoded (`Colors.white`, `Colors.black`, `Color(0xFF...)`, `Colors.grey[*]`, `Colors.green[*]`, `Colors.blue[*]`, ecc.) con riferimenti al tema (`Theme.of(context).colorScheme`)
- ✅ Verificate card, chip, bottoni e dialog in dark mode
- ✅ Marker mappa mantenuti con colori semantici (blu=rifugi, arancione=bivacchi, verde=malghe) — scelta intenzionale
- ✅ Galleria immagini e placeholder aggiornati per dark mode
- ✅ Onboarding e schermata donazioni aggiornati per dark mode
- ✅ Elementi branded (share card, passaporto, mountain pattern) lasciati intenzionali — hanno sfondi gradient custom
- 🔲 Testare su dispositivo fisico sia light che dark (i colori su schermo reale differiscono dall'emulatore)
- **File modificati**: `main.dart`, `lista_rifugi_screen.dart`, `settings_screen.dart`, `profilo_screen.dart`, `donations_screen.dart`, `onboarding_screen.dart`, `dettaglio_rifugio_screen.dart`, `offline_map_screen.dart`, `weather_widget.dart`, `rifugio_card.dart`, `image_gallery.dart`, `rifugio_image.dart`, `checkin_section.dart`, `contacts_section.dart`, `header_section.dart`, `map_section.dart`
- **File esclusi** (design branded intenzionale): `share_checkin_card.dart`, `share_dialog.dart`, `mountain_pattern_painter.dart`, `passaporto_screen.dart`

### 🔴 Audit stringhe hardcoded e localizzazione
- 🔲 Scansione **sistematica di tutti i file** in `lib/` alla ricerca di stringhe in italiano non passate per `AppLocalizations`
- 🔲 Estrarre tutte le stringhe hardcoded trovate verso i file ARB (`app_it.arb` come template)
- 🔲 Includere in particolare: `passaporto_screen.dart`, `weather.dart` (descrizioni meteo WMO), `settings_screen.dart`, widget estratti in `widgets/dettaglio/`, `donations_screen.dart`, `onboarding_screen.dart`, `offline_map_screen.dart`
- 🔲 Verificare che **placeholder e parametri** (nomi, numeri, date) usino la sintassi ICU corretta nei file ARB
- 🔲 Completare traduzioni EN, DE, FR per tutte le stringhe nuove e quelle estratte
- 🔲 Eseguire `flutter gen-l10n` e verificare che la compilazione sia pulita
- 🔲 Testare l'app con locale forzato a EN, DE, FR per verificare che non compaiano stringhe in italiano
- **File coinvolti**: `app_it.arb`, `app_en.arb`, `app_de.arb`, `app_fr.arb`, tutti gli screen e widget con stringhe visibili all'utente

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

### 🟡 Note e foto nei check-in
- 🔲 Aggiungere campo **nota** al UI del check-in (il modello `RifugioCheckin` ha già il campo `note`)
- 🔲 Aggiungere possibilità di **scattare/allegare una foto** al check-in (campo `fotoUrl` già nel modello)
- 🔲 Upload foto su Firebase Storage
- 🔲 Mostrare nota e foto nella vista passaporto e nella card di condivisione
- **File coinvolti**: `dettaglio_rifugio_screen.dart`, `passaporto_screen.dart`, `passaporto_provider.dart`, `passaporto_service.dart`, `share_checkin_card.dart`

### ✅ Debito tecnico
- ✅ Spezzato `dettaglio_rifugio_screen.dart` (1452→~260 righe) in 8 widget separati in `lib/widgets/dettaglio/`
- ✅ Estratto `MountainPatternPainter` duplicato in widget condiviso `lib/widgets/mountain_pattern_painter.dart`
- ✅ Versione app dinamica con `package_info_plus` in `settings_screen.dart`
- ✅ Configurato `appStoreId: '6740241514'` per `in_app_review`
- ✅ Creato `AnalyticsService` con 12 custom event Firebase Analytics
- ✅ Ripristinato submodule `site/` con `.gitmodules` corretto

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

### 🟡 Segnalazioni gestori rifugio (Fase 1)
- 🔲 Bottone **"Sei il gestore? Segnala una modifica"** nel dettaglio rifugio
- 🔲 Form di segnalazione: nome gestore, ruolo, campi da modificare (contatti, orari, servizi, descrizione, foto), nota libera
- 🔲 Invio segnalazione salvata su Firestore come richiesta pending
- 🔲 Notifica via email all'admin (Cloud Functions trigger su nuova segnalazione)
- 🔲 Pannello admin minimale (web o sezione nascosta in-app) per approvare/rifiutare le segnalazioni
- 🔲 Tracking stato segnalazione: pending → approvata / rifiutata, con feedback al gestore
- **Backend**: nuova collection Firestore `changeRequests/{id}` con campi: `rifugioId`, `requesterId`, `requesterName`, `requesterRole`, `changes` (mappa chiave→valore), `note`, `status`, `createdAt`, `reviewedAt`, `reviewedBy`
- **Dipendenze**: `firebase_messaging` o email per notifiche, Cloud Functions per trigger
- **File coinvolti**: nuovo `segnalazione_gestore_screen.dart`, `dettaglio_rifugio_screen.dart` (bottone), nuove Firestore rules

### 🟡 Badge "Rifugio Verificato"
- 🔲 Concetto di **rifugio verificato**: le informazioni sono state confermate o aggiornate direttamente dal gestore
- 🔲 **Badge visivo** (icona ✓ con tooltip) visibile ovunque appaia il rifugio: card nella lista, dettaglio, mappa (marker differenziato), passaporto
- 🔲 **Sezione nel dettaglio**: "Informazioni verificate dal gestore" con data ultima verifica
- 🔲 Un rifugio diventa verificato quando una segnalazione del gestore viene approvata (Fase 1) o quando il gestore conferma i dati dalla dashboard (Fase 2)
- 🔲 **Scadenza verifica**: il badge ha una validità temporale (es. 12 mesi); dopo la scadenza il rifugio torna "non verificato" e il gestore riceve un promemoria per riconfermare i dati
- 🔲 Filtro **"Solo rifugi verificati"** nella ricerca
- 🔲 Ordinamento con priorità ai rifugi verificati (opzionale, a scelta dell'utente)
- **Backend**: nuovi campi nel documento `rifugi/{id}`: `verified` (bool), `verifiedAt` (timestamp), `verifiedBy` (uid gestore), `verificationExpiresAt` (timestamp). Cloud Function schedulata per reset scadenze
- **Modello dati**: aggiornare `Rifugio` in `rifugio.dart` con campi `verified`, `verifiedAt`, `verifiedBy`
- **File coinvolti**: `rifugio.dart`, `rifugio_card.dart`, `dettaglio_rifugio_screen.dart`, `filtro_provider.dart`, `rifugi_provider.dart`, nuovo widget `verified_badge.dart`

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

### 🟡 Pannello gestori rifugio (Fase 2)
- 🔲 Ruolo **"gestore"** nel sistema: utenti verificati associati a uno o più rifugi
- 🔲 Flusso di **verifica gestore**: richiesta claim rifugio → verifica manuale (email/telefono al rifugio) → approvazione
- 🔲 **Dashboard gestore** in-app: modifica diretta dei dati del proprio rifugio (contatti, servizi, orari, descrizione, foto, periodi apertura) senza approvazione admin
- 🔲 **Conferma periodica dati**: pulsante "Confermo che i dati sono aggiornati" che rinnova il badge verificato senza dover modificare nulla
- 🔲 Storico modifiche con versioning (chi ha modificato cosa e quando)
- 🔲 Possibilità per il gestore di rispondere alle recensioni degli utenti (dipende da v1.3 Recensioni)
- 🔲 Notifiche al gestore: nuove recensioni, nuovi check-in al proprio rifugio, **promemoria rinnovo verifica** in prossimità della scadenza
- 🔲 Statistiche per il gestore: visualizzazioni del rifugio, check-in, preferiti, **stato verifica e storico**
- **Backend**: campo `role` in `users/{uid}` (`user` | `gestore` | `admin`), collection `gestori/{uid}` con `rifugiIds[]` e `verifiedAt`, Firestore rules con write condizionato al ruolo, Cloud Functions per verifica, notifiche e scadenza badge
- **File coinvolti**: nuovo `gestore_dashboard_screen.dart`, `auth_provider.dart` (ruoli), `auth_service.dart` (claims), nuove Firestore rules avanzate
- **Note**: valutare Firebase Custom Claims per ruoli server-side vs campo Firestore; Custom Claims è più sicuro ma richiede Cloud Functions per l'assegnazione

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
| Portale web gestori | Dashboard web (Flutter web o React) per gestori che preferiscono lavorare da desktop |
| Gestione collaborativa multi-gestore | Più gestori per lo stesso rifugio con ruoli (proprietario, collaboratore) |
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
