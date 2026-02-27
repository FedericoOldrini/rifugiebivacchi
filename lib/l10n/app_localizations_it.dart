// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Rifugi e Bivacchi';

  @override
  String get tabList => 'Lista';

  @override
  String get tabMap => 'Mappa';

  @override
  String get tabProfile => 'Profilo';

  @override
  String get searchHint => 'Cerca rifugi o bivacchi...';

  @override
  String get loadingRifugi => 'Caricamento rifugi...';

  @override
  String get syncingFirebase => 'Sincronizzazione con Firebase...';

  @override
  String get error => 'Errore';

  @override
  String get noFavoriteRifugi => 'Nessun rifugio preferito';

  @override
  String get noRifugiFound => 'Nessun rifugio trovato';

  @override
  String get addFavoritesHint => 'Aggiungi dei rifugi ai preferiti';

  @override
  String get modifySearchHint => 'Prova a modificare la ricerca';

  @override
  String get likeThisApp => 'Ti piace questa app?';

  @override
  String get supportDevelopment => 'Supporta lo sviluppo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get appInfo => 'Informazioni App';

  @override
  String get version => 'Versione';

  @override
  String get information => 'Informazioni';

  @override
  String get appDescription => 'Rifugi e Bivacchi - App per escursionisti';

  @override
  String get appAboutDescription =>
      'App per visualizzare rifugi e bivacchi di montagna nelle Alpi italiane. Utilizza la mappa per trovare i rifugi vicino a te o cerca per nome.';

  @override
  String get privacyAndPermissions => 'Privacy e Permessi';

  @override
  String get locationPermissions => 'Permessi posizione';

  @override
  String get locationPermissionsDesc =>
      'Gestisci i permessi di accesso alla posizione';

  @override
  String get locationPermissionsDialog =>
      'L\'app richiede l\'accesso alla tua posizione per mostrarti i rifugi nelle vicinanze sulla mappa. Puoi modificare i permessi nelle impostazioni del sistema.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyDesc => 'La tua posizione non viene memorizzata';

  @override
  String get privacyDialog =>
      'Questa app non memorizza né condivide la tua posizione. I dati di localizzazione vengono utilizzati solo per mostrare la mappa centrata sulla tua posizione corrente.';

  @override
  String get help => 'Aiuto';

  @override
  String get reviewOnboarding => 'Rivedi introduzione';

  @override
  String get reviewOnboardingDesc =>
      'Visualizza di nuovo l\'onboarding iniziale';

  @override
  String get supportProject => 'Supporta il Progetto';

  @override
  String get supportUs => 'Supportaci';

  @override
  String get supportUsDesc => 'Fai una donazione per supportare lo sviluppo';

  @override
  String get rateApp => 'Valuta l\'app';

  @override
  String get rateAppDesc => 'Lascia una recensione sullo store';

  @override
  String get rateAppThanks => 'Grazie per il tuo supporto!';

  @override
  String get rateAppNotAvailable =>
      'Valutazione non disponibile su questo dispositivo';

  @override
  String get madeWithLove => 'Made with ❤️ for mountain lovers';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Chiudi';

  @override
  String get share => 'Condividi';

  @override
  String get showAll => 'Mostra tutti';

  @override
  String get onlyFavorites => 'Solo preferiti';

  @override
  String get profile => 'Profilo';

  @override
  String get rifugio => 'Rifugio';

  @override
  String get bivacco => 'Bivacco';

  @override
  String get malga => 'Malga';

  @override
  String get altitude => 'Altitudine';

  @override
  String altitudeValue(int meters) {
    return '$meters m s.l.m.';
  }

  @override
  String beds(int count) {
    return '$count posti letto';
  }

  @override
  String bedsShort(int count) {
    return '$count posti';
  }

  @override
  String get locality => 'Località';

  @override
  String get municipality => 'Comune';

  @override
  String get valley => 'Valle';

  @override
  String get region => 'Regione';

  @override
  String get buildYear => 'Anno di costruzione';

  @override
  String get coordinates => 'Coordinate';

  @override
  String get position => 'Posizione';

  @override
  String get informazioni => 'Informazioni';

  @override
  String get services => 'Servizi';

  @override
  String get accessibility => 'Accessibilità';

  @override
  String get management => 'Gestione';

  @override
  String get contacts => 'Contatti';

  @override
  String get manager => 'Gestore';

  @override
  String get property => 'Proprietà';

  @override
  String get type => 'Tipo';

  @override
  String get restaurant => 'Ristorante';

  @override
  String restaurantWithSeats(int seats) {
    return 'Ristorante ($seats posti)';
  }

  @override
  String get wifi => 'WiFi';

  @override
  String get electricity => 'Elettricità';

  @override
  String get pos => 'POS';

  @override
  String get defibrillator => 'Defibrillatore';

  @override
  String get hotWater => 'Acqua calda';

  @override
  String get showers => 'Docce';

  @override
  String get insideWater => 'Acqua interna';

  @override
  String get car => 'Auto';

  @override
  String get mtb => 'MTB';

  @override
  String get disabled => 'Disabili';

  @override
  String get disabledWc => 'WC disabili';

  @override
  String get families => 'Famiglie';

  @override
  String get pets => 'Animali';

  @override
  String get website => 'Sito web';

  @override
  String get openInGoogleMaps => 'Apri in Google Maps';

  @override
  String get checkIn => 'Fai Check-in';

  @override
  String get checkInAgain => 'Fai Check-in di nuovo';

  @override
  String get checkInProgress => 'Check-in in corso...';

  @override
  String get checkInDone => 'Check-in effettuato!';

  @override
  String get checkInRadius => 'Devi essere nel raggio di 100 metri dal rifugio';

  @override
  String get checkInAlreadyToday =>
      'Hai già fatto check-in oggi! Torna domani per registrare una nuova visita.';

  @override
  String get visitedOnce => 'Hai visitato questo rifugio!';

  @override
  String visitedMultiple(int count) {
    return 'Hai visitato questo rifugio $count volte!';
  }

  @override
  String firstVisit(String date) {
    return 'Prima visita: $date';
  }

  @override
  String lastVisit(String date) {
    return 'Ultima visita: $date';
  }

  @override
  String get removedFromFavorites => 'Rimosso dai preferiti';

  @override
  String get addedToFavorites => 'Aggiunto ai preferiti';

  @override
  String get shareCheckIn => 'Vuoi condividere il tuo check-in sui social?';

  @override
  String visitNumber(int number) {
    return 'Visita n. $number';
  }

  @override
  String get firstTimeWelcome =>
      'Benvenuto per la prima volta in questo rifugio!';

  @override
  String congratsVisit(int count) {
    return 'Congratulazioni! Questa è la tua visita numero $count a questo rifugio! 🎉';
  }

  @override
  String shareError(String error) {
    return 'Errore nella condivisione: $error';
  }

  @override
  String get imageGenerationError => 'Errore nella generazione dell\'immagine';

  @override
  String get passaportoTitle => 'Il Mio Passaporto';

  @override
  String get passaportoRifugi => 'Passaporto dei Rifugi';

  @override
  String get loginRequired =>
      'Devi effettuare il login per accedere al passaporto';

  @override
  String nRifugi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rifugi',
      one: '1 rifugio',
    );
    return '$_temp0';
  }

  @override
  String get donations => 'Donazioni';

  @override
  String get donationThanks => 'Grazie per il tuo supporto! ❤️';

  @override
  String errorLabel(String error) {
    return 'Errore: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in Rifugi e Bivacchi';

  @override
  String get onboardingWelcomeDesc =>
      'Scopri migliaia di rifugi, bivacchi e malghe nelle Alpi italiane. Pianifica le tue escursioni in montagna con facilità.';

  @override
  String get onboardingSearchTitle => 'Cerca e Trova';

  @override
  String get onboardingSearchDesc =>
      'Cerca rifugi per nome, zona o altitudine. Filtra i risultati per trovare il rifugio perfetto per la tua avventura.';

  @override
  String get onboardingMapTitle => 'Visualizza sulla Mappa';

  @override
  String get onboardingMapDesc =>
      'Esplora i rifugi sulla mappa interattiva. Visualizza la loro posizione e ottieni indicazioni stradali.';

  @override
  String get onboardingAccountTitle => 'Account Opzionale';

  @override
  String get onboardingAccountDesc =>
      'Accedi con Google o Apple per salvare i tuoi rifugi preferiti e sincronizzarli tra dispositivi. Oppure continua senza account.';

  @override
  String get onboardingLocationTitle => 'Permesso Localizzazione';

  @override
  String get onboardingLocationDesc =>
      'Per mostrarti i rifugi più vicini e fornirti indicazioni, abbiamo bisogno di accedere alla tua posizione.';

  @override
  String get legendRifugi => 'Rifugi';

  @override
  String get legendBivacchi => 'Bivacchi';

  @override
  String get legendMalghe => 'Malghe';

  @override
  String nRifugiInArea(int count) {
    return '$count rifugi in questa zona';
  }

  @override
  String get tapToExpand => 'Tocca per espandere';

  @override
  String get offlineMap => 'Mappa Offline';

  @override
  String get offlineMapDesc =>
      'Mappa OpenStreetMap disponibile anche senza connessione';

  @override
  String get mapGoogle => 'Google Maps';

  @override
  String get mapOffline => 'Mappa Offline';

  @override
  String get myItineraries => 'I Miei Itinerari';

  @override
  String get comingSoon => 'Prossimamente disponibile';

  @override
  String get logout => 'Esci';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get language => 'Lingua';

  @override
  String get confirmLogout => 'Conferma Logout';

  @override
  String get confirmLogoutMessage => 'Vuoi disconnetterti dal tuo account?';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirmDeleteAccount => 'Elimina Account';

  @override
  String get confirmDeleteAccountMessage =>
      'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile e perderai tutti i tuoi dati.';

  @override
  String get delete => 'Elimina';

  @override
  String get accountDeleted => 'Account eliminato con successo';

  @override
  String get loginToAccount => 'Accedi al tuo account';

  @override
  String get loginDescription =>
      'Accedi per salvare i tuoi rifugi preferiti, tenere traccia delle tue visite e sincronizzare i dati tra dispositivi.';

  @override
  String get continueWithGoogle => 'Accedi con Google';

  @override
  String get continueWithApple => 'Accedi con Apple';

  @override
  String get continueWithoutAccount =>
      'Puoi continuare ad usare l\'app anche senza effettuare il login.';

  @override
  String get continueWithoutAccountOnboarding => 'Continua senza account';

  @override
  String get continueWithGoogleOnboarding => 'Continua con Google';

  @override
  String get continueWithAppleOnboarding => 'Continua con Apple';

  @override
  String get rifugiPreferiti => 'Rifugi Preferiti';

  @override
  String nRifugiVisitati(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rifugi visitati',
      one: '1 rifugio visitato',
    );
    return '$_temp0';
  }

  @override
  String get noPreferiti =>
      'Nessun rifugio preferito.\nAggiungi i tuoi preferiti dalla lista!';

  @override
  String andOthers(int count) {
    return 'e altri $count...';
  }

  @override
  String get skip => 'Salta';

  @override
  String get next => 'Avanti';

  @override
  String get allowLocation => 'Consenti Posizione';

  @override
  String get permissionDenied => 'Permesso Negato';

  @override
  String get permissionDeniedMessage =>
      'Il permesso di localizzazione è stato negato permanentemente. Puoi abilitarlo manualmente dalle impostazioni del dispositivo.';

  @override
  String get continueWithoutPermission => 'Continua senza permesso';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get permissionDeniedSnack =>
      'Permesso negato. Puoi concederlo in seguito dalle impostazioni.';

  @override
  String get supportDevelopmentTitle => 'Supporta lo Sviluppo';

  @override
  String get supportDevelopmentDescription =>
      'Se ti piace questa app e vuoi supportare lo sviluppo, considera di fare una donazione!';

  @override
  String get donationsInApp => 'Donazioni In-App';

  @override
  String get donationsNotAvailableNote =>
      'Nota: Durante lo sviluppo, le donazioni potrebbero non essere disponibili. L\'app funziona comunque!';

  @override
  String get inAppPurchasesNotAvailable =>
      'Gli acquisti in-app non sono disponibili';

  @override
  String get whyDonate => 'Perché donare?';

  @override
  String get regularUpdates => 'Aggiornamenti regolari';

  @override
  String get regularUpdatesDesc =>
      'Nuove funzionalità e miglioramenti continui';

  @override
  String get moreRifugi => 'Più rifugi';

  @override
  String get moreRifugiDesc => 'Espansione del database con nuovi rifugi';

  @override
  String get supportAndBugfix => 'Supporto e bug fix';

  @override
  String get supportAndBugfixDesc => 'Risoluzione rapida di problemi e bug';

  @override
  String get newFeatures => 'Nuove funzionalità';

  @override
  String get newFeaturesDesc =>
      'Sviluppo di features richieste dalla community';

  @override
  String get donationOptions => 'Opzioni di donazione';

  @override
  String get buyCoffee => 'Offrimi un caffè';

  @override
  String get buyLunch => 'Offrimi un pranzo';

  @override
  String get generousDonation => 'Donazione generosa';

  @override
  String get donation => 'Donazione';

  @override
  String get notAvailable => 'Non disponibile';

  @override
  String get donationsInfo =>
      'Le donazioni sono pagamenti una tantum e non comportano abbonamenti.';

  @override
  String get thanksSupport => 'Grazie per il tuo supporto! 🏔️';

  @override
  String purchaseError(String error) {
    return 'Errore: $error';
  }

  @override
  String get cannotStartPurchase => 'Impossibile avviare l\'acquisto';

  @override
  String get passaportoEmpty => 'Nessun timbro ancora';

  @override
  String get passaportoEmptyDesc =>
      'Visita i rifugi e fai check-in per collezionare i tuoi timbri!';

  @override
  String get sharePassaporto => 'Condividi il mio passaporto';

  @override
  String get rifugioNotFound => 'Rifugio non trovato';

  @override
  String get nearRifugioRequired =>
      'Devi essere vicino al rifugio (entro 100 metri) per fare check-in';

  @override
  String checkInShareText(String name, int count) {
    return '🏔️ Check-in al $name!\nVisita n. $count\n#RifugiEBivacchi #Montagna #Trekking';
  }

  @override
  String get meteo => 'Meteo';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get nextDays => 'Prossimi giorni';

  @override
  String get today => 'Oggi';

  @override
  String get dataOpenMeteo => 'Dati Open-Meteo';

  @override
  String nRifugiInAreaCount(int count) {
    return '$count rifugi in questa zona';
  }

  @override
  String bedsCount(int count) {
    return '$count posti letto';
  }

  @override
  String get firebaseInitError =>
      'L\'app funzionerà comunque, ma senza autenticazione.';

  @override
  String get gallery => 'Galleria';

  @override
  String nPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get imageLoadError => 'Impossibile caricare l\'immagine';

  @override
  String get weatherClear => 'Sereno';

  @override
  String get weatherMostlyClear => 'Prevalentemente sereno';

  @override
  String get weatherPartlyCloudy => 'Parzialmente nuvoloso';

  @override
  String get weatherCloudy => 'Nuvoloso';

  @override
  String get weatherFog => 'Nebbia';

  @override
  String get weatherDrizzle => 'Pioggerella';

  @override
  String get weatherLightRain => 'Pioggia leggera';

  @override
  String get weatherModerateRain => 'Pioggia moderata';

  @override
  String get weatherHeavyRain => 'Pioggia intensa';

  @override
  String get weatherLightSnow => 'Neve leggera';

  @override
  String get weatherModerateSnow => 'Neve moderata';

  @override
  String get weatherHeavySnow => 'Neve intensa';

  @override
  String get weatherSnowGrains => 'Granuli di neve';

  @override
  String get weatherShowers => 'Rovesci';

  @override
  String get weatherSnowShowers => 'Rovesci di neve';

  @override
  String get weatherThunderstorm => 'Temporale';

  @override
  String get weatherThunderstormHail => 'Temporale con grandine';

  @override
  String get weatherNotAvailable => 'Meteo non disponibile';

  @override
  String nVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visite',
      one: '1 visita',
    );
    return '$_temp0';
  }

  @override
  String get firstVisitLabel => 'Prima visita';

  @override
  String get lastVisitLabel => 'Ultima visita';

  @override
  String get visited => 'VISITATO';

  @override
  String shareVisitLabel(int count) {
    return 'VISITA N. $count';
  }

  @override
  String get shareCheckInLabel => 'CHECK-IN';

  @override
  String get shareAltitudeUnit => 'm s.l.m.';

  @override
  String get shareHashtags => '#RifugiEBivacchi #Montagna #Trekking';

  @override
  String shareAltitude(int meters) {
    return '📍 $meters m';
  }

  @override
  String get shareMyPassportTitle => 'IL MIO PASSAPORTO';

  @override
  String get shareOfSheltersTitle => 'DEI RIFUGI';

  @override
  String get shareVisitSingular => 'VISITA';

  @override
  String get shareVisitPlural => 'VISITE';

  @override
  String get shareShelterSingular => 'RIFUGIO';

  @override
  String get shareShelterPlural => 'RIFUGI';

  @override
  String get shareMaxAltitude => 'ALTITUDINE MAX';

  @override
  String get shareSheltersVisited => 'RIFUGI VISITATI';

  @override
  String get shareTrueExplorer => 'Vero Esploratore!';

  @override
  String shareVisitedCount(int count) {
    return 'Hai visitato $count rifugi!';
  }

  @override
  String get sharePassaportoHashtags =>
      '#RifugiEBivacchi #PassaportoDeiRifugi #Montagna';

  @override
  String sharePassaportoText(int count) {
    return '🏔️ Il mio passaporto dei rifugi!\n$count rifugi visitati\n#RifugiEBivacchi';
  }

  @override
  String get errorIapNotAvailable =>
      'Acquisti in-app non disponibili su questo dispositivo';

  @override
  String get errorIapProductsNotConfigured =>
      'Prodotti non ancora configurati. Le donazioni saranno disponibili a breve.';

  @override
  String get errorIapNoProductsFound =>
      'Nessun prodotto trovato. Riprova più tardi.';

  @override
  String errorIapProductLoadError(String details) {
    return 'Errore nel caricamento dei prodotti: $details';
  }

  @override
  String get errorIapConnectionError =>
      'Errore di connessione. Verifica la connessione Internet e riprova.';

  @override
  String get errorInitialization =>
      'Errore nell\'inizializzazione dell\'app. Riprova.';

  @override
  String get errorLoadingRifugi =>
      'Errore nel caricamento dei rifugi. Riprova.';

  @override
  String get errorLoginGeneric => 'Errore durante l\'accesso. Riprova.';
}
