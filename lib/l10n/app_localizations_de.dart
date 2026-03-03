// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Berghütten';

  @override
  String get tabList => 'Liste';

  @override
  String get tabMap => 'Karte';

  @override
  String get tabProfile => 'Profil';

  @override
  String get searchHint => 'Hütten suchen...';

  @override
  String get loadingRifugi => 'Hütten werden geladen...';

  @override
  String get syncingFirebase => 'Synchronisierung mit Firebase...';

  @override
  String get error => 'Fehler';

  @override
  String get noFavoriteRifugi => 'Keine Lieblingshütten';

  @override
  String get noRifugiFound => 'Keine Hütten gefunden';

  @override
  String get addFavoritesHint => 'Füge Hütten zu deinen Favoriten hinzu';

  @override
  String get modifySearchHint => 'Versuche die Suche anzupassen';

  @override
  String get likeThisApp => 'Gefällt dir diese App?';

  @override
  String get supportDevelopment => 'Unterstütze die Entwicklung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appInfo => 'App-Info';

  @override
  String get version => 'Version';

  @override
  String get information => 'Informationen';

  @override
  String get appDescription => 'Berghütten - App für Wanderer';

  @override
  String get appAboutDescription =>
      'App zur Erkundung von Berghütten und Biwaks in den italienischen Alpen. Nutze die Karte, um Hütten in deiner Nähe zu finden oder suche nach Namen.';

  @override
  String get privacyAndPermissions => 'Datenschutz & Berechtigungen';

  @override
  String get locationPermissions => 'Standortberechtigungen';

  @override
  String get locationPermissionsDesc => 'Standortzugriff verwalten';

  @override
  String get locationPermissionsDialog =>
      'Die App benötigt Zugriff auf deinen Standort, um nahegelegene Hütten auf der Karte anzuzeigen. Du kannst die Berechtigungen in den Systemeinstellungen ändern.';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacyDesc => 'Dein Standort wird nicht gespeichert';

  @override
  String get privacyDialog =>
      'Diese App speichert oder teilt deinen Standort nicht. Standortdaten werden nur verwendet, um die Karte auf deine aktuelle Position zu zentrieren.';

  @override
  String get help => 'Hilfe';

  @override
  String get reviewOnboarding => 'Einführung erneut ansehen';

  @override
  String get reviewOnboardingDesc => 'Das Onboarding erneut anzeigen';

  @override
  String get supportProject => 'Projekt unterstützen';

  @override
  String get supportUs => 'Unterstütze uns';

  @override
  String get supportUsDesc => 'Spende zur Unterstützung der Entwicklung';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get rateAppDesc => 'Hinterlasse eine Bewertung im Store';

  @override
  String get rateAppThanks => 'Danke für deine Unterstützung!';

  @override
  String get rateAppNotAvailable =>
      'Bewertung auf diesem Gerät nicht verfügbar';

  @override
  String get madeWithLove => 'Made with ❤️ for mountain lovers';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get share => 'Teilen';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get onlyFavorites => 'Nur Favoriten';

  @override
  String get profile => 'Profil';

  @override
  String get rifugio => 'Schutzhütte';

  @override
  String get bivacco => 'Biwak';

  @override
  String get malga => 'Almhütte';

  @override
  String get altitude => 'Höhe';

  @override
  String altitudeValue(int meters) {
    return '$meters m ü.M.';
  }

  @override
  String beds(int count) {
    return '$count Schlafplätze';
  }

  @override
  String bedsShort(int count) {
    return '$count Plätze';
  }

  @override
  String get locality => 'Ortschaft';

  @override
  String get municipality => 'Gemeinde';

  @override
  String get valley => 'Tal';

  @override
  String get region => 'Region';

  @override
  String get buildYear => 'Baujahr';

  @override
  String get coordinates => 'Koordinaten';

  @override
  String get position => 'Lage';

  @override
  String get informazioni => 'Informationen';

  @override
  String get services => 'Dienste';

  @override
  String get accessibility => 'Zugänglichkeit';

  @override
  String get management => 'Verwaltung';

  @override
  String get contacts => 'Kontakte';

  @override
  String get manager => 'Verwalter';

  @override
  String get property => 'Eigentum';

  @override
  String get type => 'Typ';

  @override
  String get restaurant => 'Restaurant';

  @override
  String restaurantWithSeats(int seats) {
    return 'Restaurant ($seats Plätze)';
  }

  @override
  String get wifi => 'WLAN';

  @override
  String get electricity => 'Strom';

  @override
  String get pos => 'Kartenzahlung';

  @override
  String get defibrillator => 'Defibrillator';

  @override
  String get hotWater => 'Warmwasser';

  @override
  String get showers => 'Duschen';

  @override
  String get insideWater => 'Innenwasser';

  @override
  String get car => 'Auto';

  @override
  String get mtb => 'MTB';

  @override
  String get disabled => 'Barrierefrei';

  @override
  String get disabledWc => 'Behinderten-WC';

  @override
  String get families => 'Familien';

  @override
  String get pets => 'Haustiere';

  @override
  String get website => 'Webseite';

  @override
  String get openInGoogleMaps => 'In Google Maps öffnen';

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkInAgain => 'Erneut einchecken';

  @override
  String get checkInProgress => 'Check-in läuft...';

  @override
  String get checkInDone => 'Check-in erledigt!';

  @override
  String get checkInRadius =>
      'Du musst innerhalb von 100 Metern der Hütte sein';

  @override
  String get checkInAlreadyToday =>
      'Du hast heute schon eingecheckt! Komm morgen wieder für einen neuen Besuch.';

  @override
  String get visitedOnce => 'Du hast diese Hütte besucht!';

  @override
  String visitedMultiple(int count) {
    return 'Du hast diese Hütte $count Mal besucht!';
  }

  @override
  String firstVisit(String date) {
    return 'Erster Besuch: $date';
  }

  @override
  String lastVisit(String date) {
    return 'Letzter Besuch: $date';
  }

  @override
  String get removedFromFavorites => 'Aus Favoriten entfernt';

  @override
  String get addedToFavorites => 'Zu Favoriten hinzugefügt';

  @override
  String get shareCheckIn =>
      'Möchtest du deinen Check-in in sozialen Medien teilen?';

  @override
  String visitNumber(int number) {
    return 'Besuch Nr. $number';
  }

  @override
  String get firstTimeWelcome => 'Willkommen zum ersten Mal in dieser Hütte!';

  @override
  String congratsVisit(int count) {
    return 'Herzlichen Glückwunsch! Dies ist dein Besuch Nummer $count in dieser Hütte! 🎉';
  }

  @override
  String shareError(String error) {
    return 'Fehler beim Teilen: $error';
  }

  @override
  String get imageGenerationError => 'Fehler bei der Bilderzeugung';

  @override
  String get passaportoTitle => 'Mein Pass';

  @override
  String get passaportoRifugi => 'Hüttenpass';

  @override
  String get loginRequired =>
      'Du musst dich anmelden, um auf den Pass zuzugreifen';

  @override
  String nRifugi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hütten',
      one: '1 Hütte',
    );
    return '$_temp0';
  }

  @override
  String get donations => 'Spenden';

  @override
  String get donationThanks => 'Danke für deine Unterstützung! ❤️';

  @override
  String errorLabel(String error) {
    return 'Fehler: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Berghütten';

  @override
  String get onboardingWelcomeDesc =>
      'Entdecke Tausende von Hütten, Biwaks und Almhütten in den italienischen Alpen. Plane deine Bergwanderungen mit Leichtigkeit.';

  @override
  String get onboardingSearchTitle => 'Suchen und Finden';

  @override
  String get onboardingSearchDesc =>
      'Suche Hütten nach Name, Gebiet oder Höhe. Filtere die Ergebnisse, um die perfekte Hütte für dein Abenteuer zu finden.';

  @override
  String get onboardingMapTitle => 'Auf der Karte anzeigen';

  @override
  String get onboardingMapDesc =>
      'Erkunde Hütten auf der interaktiven Karte. Sieh ihren Standort und erhalte Wegbeschreibungen.';

  @override
  String get onboardingAccountTitle => 'Optionales Konto';

  @override
  String get onboardingAccountDesc =>
      'Melde dich mit Google oder Apple an, um deine Lieblingshütten zu speichern und geräteübergreifend zu synchronisieren. Oder fahre ohne Konto fort.';

  @override
  String get onboardingLocationTitle => 'Standortberechtigung';

  @override
  String get onboardingLocationDesc =>
      'Um dir die nächsten Hütten zu zeigen und Wegbeschreibungen zu liefern, benötigen wir Zugriff auf deinen Standort.';

  @override
  String get legendRifugi => 'Schutzhütten';

  @override
  String get legendBivacchi => 'Biwaks';

  @override
  String get legendMalghe => 'Almhütten';

  @override
  String nRifugiInArea(int count) {
    return '$count Hütten in diesem Gebiet';
  }

  @override
  String get tapToExpand => 'Tippe zum Erweitern';

  @override
  String get offlineMap => 'Offline-Karte';

  @override
  String get offlineMapDesc => 'OpenStreetMap auch ohne Verbindung verfügbar';

  @override
  String get mapGoogle => 'Google Maps';

  @override
  String get mapOffline => 'Offline-Karte';

  @override
  String get myItineraries => 'Meine Routen';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get logout => 'Abmelden';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get language => 'Sprache';

  @override
  String get confirmLogout => 'Abmeldung bestätigen';

  @override
  String get confirmLogoutMessage =>
      'Möchtest du dich von deinem Konto abmelden?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirmDeleteAccount => 'Konto löschen';

  @override
  String get confirmDeleteAccountMessage =>
      'Bist du sicher, dass du dein Konto löschen möchtest? Diese Aktion ist unwiderruflich und alle Daten gehen verloren.';

  @override
  String get delete => 'Löschen';

  @override
  String get accountDeleted => 'Konto erfolgreich gelöscht';

  @override
  String get loginToAccount => 'Bei deinem Konto anmelden';

  @override
  String get loginDescription =>
      'Melde dich an, um deine Lieblingshütten zu speichern, Besuche zu verfolgen und Daten zwischen Geräten zu synchronisieren.';

  @override
  String get continueWithGoogle => 'Mit Google anmelden';

  @override
  String get continueWithApple => 'Mit Apple anmelden';

  @override
  String get continueWithoutAccount =>
      'Du kannst die App auch ohne Anmeldung weiter nutzen.';

  @override
  String get continueWithoutAccountOnboarding => 'Ohne Konto fortfahren';

  @override
  String get continueWithGoogleOnboarding => 'Weiter mit Google';

  @override
  String get continueWithAppleOnboarding => 'Weiter mit Apple';

  @override
  String get rifugiPreferiti => 'Lieblingshütten';

  @override
  String nRifugiVisitati(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hütten besucht',
      one: '1 Hütte besucht',
    );
    return '$_temp0';
  }

  @override
  String get noPreferiti =>
      'Keine Lieblingshütten.\nFüge deine Favoriten aus der Liste hinzu!';

  @override
  String andOthers(int count) {
    return 'und $count weitere...';
  }

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get allowLocation => 'Standort erlauben';

  @override
  String get permissionDenied => 'Berechtigung verweigert';

  @override
  String get permissionDeniedMessage =>
      'Die Standortberechtigung wurde dauerhaft verweigert. Du kannst sie manuell in den Geräteeinstellungen aktivieren.';

  @override
  String get continueWithoutPermission => 'Ohne Berechtigung fortfahren';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get permissionDeniedSnack =>
      'Berechtigung verweigert. Du kannst sie später in den Einstellungen erteilen.';

  @override
  String get supportDevelopmentTitle => 'Entwicklung unterstützen';

  @override
  String get supportDevelopmentDescription =>
      'Wenn dir diese App gefällt und du die Entwicklung unterstützen möchtest, erwäge eine Spende!';

  @override
  String get donationsInApp => 'In-App-Spenden';

  @override
  String get donationsNotAvailableNote =>
      'Hinweis: Während der Entwicklung sind Spenden möglicherweise nicht verfügbar. Die App funktioniert trotzdem!';

  @override
  String get inAppPurchasesNotAvailable => 'In-App-Käufe sind nicht verfügbar';

  @override
  String get whyDonate => 'Warum spenden?';

  @override
  String get regularUpdates => 'Regelmäßige Updates';

  @override
  String get regularUpdatesDesc =>
      'Neue Funktionen und kontinuierliche Verbesserungen';

  @override
  String get moreRifugi => 'Mehr Hütten';

  @override
  String get moreRifugiDesc => 'Erweiterung der Datenbank mit neuen Hütten';

  @override
  String get supportAndBugfix => 'Support und Fehlerbehebung';

  @override
  String get supportAndBugfixDesc =>
      'Schnelle Lösung von Problemen und Fehlern';

  @override
  String get newFeatures => 'Neue Funktionen';

  @override
  String get newFeaturesDesc =>
      'Entwicklung von der Community gewünschter Features';

  @override
  String get donationOptions => 'Spendenoptionen';

  @override
  String get buyCoffee => 'Spendiere mir einen Kaffee';

  @override
  String get buyLunch => 'Spendiere mir ein Mittagessen';

  @override
  String get generousDonation => 'Großzügige Spende';

  @override
  String get donation => 'Spende';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get donationsInfo =>
      'Spenden sind einmalige Zahlungen und beinhalten keine Abonnements.';

  @override
  String get thanksSupport => 'Danke für deine Unterstützung! 🏔️';

  @override
  String purchaseError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get cannotStartPurchase => 'Kauf konnte nicht gestartet werden';

  @override
  String get passaportoEmpty => 'Noch keine Stempel';

  @override
  String get passaportoEmptyDesc =>
      'Besuche Hütten und mache Check-ins, um deine Stempel zu sammeln!';

  @override
  String get sharePassaporto => 'Meinen Pass teilen';

  @override
  String get rifugioNotFound => 'Hütte nicht gefunden';

  @override
  String get nearRifugioRequired =>
      'Du musst in der Nähe der Hütte sein (innerhalb von 100 Metern) um einzuchecken';

  @override
  String checkInShareText(String name, int count) {
    return '🏔️ Check-in bei $name!\nBesuch Nr. $count\n#RifugiEBivacchi #Berge #Wandern';
  }

  @override
  String get meteo => 'Wetter';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get nextDays => 'Nächste Tage';

  @override
  String get today => 'Heute';

  @override
  String get dataOpenMeteo => 'Open-Meteo Daten';

  @override
  String nRifugiInAreaCount(int count) {
    return '$count Hütten in diesem Gebiet';
  }

  @override
  String bedsCount(int count) {
    return '$count Betten';
  }

  @override
  String get firebaseInitError =>
      'Die App funktioniert trotzdem, aber ohne Authentifizierung.';

  @override
  String get gallery => 'Galerie';

  @override
  String nPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    return '$_temp0';
  }

  @override
  String get imageLoadError => 'Bild konnte nicht geladen werden';

  @override
  String get weatherClear => 'Klar';

  @override
  String get weatherMostlyClear => 'Überwiegend klar';

  @override
  String get weatherPartlyCloudy => 'Teilweise bewölkt';

  @override
  String get weatherCloudy => 'Bewölkt';

  @override
  String get weatherFog => 'Nebel';

  @override
  String get weatherDrizzle => 'Nieselregen';

  @override
  String get weatherLightRain => 'Leichter Regen';

  @override
  String get weatherModerateRain => 'Mäßiger Regen';

  @override
  String get weatherHeavyRain => 'Starker Regen';

  @override
  String get weatherLightSnow => 'Leichter Schneefall';

  @override
  String get weatherModerateSnow => 'Mäßiger Schneefall';

  @override
  String get weatherHeavySnow => 'Starker Schneefall';

  @override
  String get weatherSnowGrains => 'Schneegriesel';

  @override
  String get weatherShowers => 'Schauer';

  @override
  String get weatherSnowShowers => 'Schneeschauer';

  @override
  String get weatherThunderstorm => 'Gewitter';

  @override
  String get weatherThunderstormHail => 'Gewitter mit Hagel';

  @override
  String get weatherNotAvailable => 'Wetter nicht verfügbar';

  @override
  String nVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Besuche',
      one: '1 Besuch',
    );
    return '$_temp0';
  }

  @override
  String get firstVisitLabel => 'Erster Besuch';

  @override
  String get lastVisitLabel => 'Letzter Besuch';

  @override
  String get visited => 'BESUCHT';

  @override
  String shareVisitLabel(int count) {
    return 'BESUCH NR. $count';
  }

  @override
  String get shareCheckInLabel => 'CHECK-IN';

  @override
  String get shareAltitudeUnit => 'm ü.M.';

  @override
  String get shareHashtags => '#Berghütten #Berge #Wandern';

  @override
  String shareAltitude(int meters) {
    return '📍 $meters m';
  }

  @override
  String get shareMyPassportTitle => 'MEIN PASS';

  @override
  String get shareOfSheltersTitle => 'DER HÜTTEN';

  @override
  String get shareVisitSingular => 'BESUCH';

  @override
  String get shareVisitPlural => 'BESUCHE';

  @override
  String get shareShelterSingular => 'HÜTTE';

  @override
  String get shareShelterPlural => 'HÜTTEN';

  @override
  String get shareMaxAltitude => 'MAX HÖHE';

  @override
  String get shareSheltersVisited => 'BESUCHTE HÜTTEN';

  @override
  String get shareTrueExplorer => 'Wahrer Entdecker!';

  @override
  String shareVisitedCount(int count) {
    return 'Du hast $count Hütten besucht!';
  }

  @override
  String get sharePassaportoHashtags => '#Berghütten #Hüttenpass #Berge';

  @override
  String sharePassaportoText(int count) {
    return '🏔️ Mein Hüttenpass!\n$count Hütten besucht\n#Berghütten';
  }

  @override
  String get errorIapNotAvailable =>
      'In-App-Käufe auf diesem Gerät nicht verfügbar';

  @override
  String get errorIapProductsNotConfigured =>
      'Produkte noch nicht konfiguriert. Spenden werden bald verfügbar sein.';

  @override
  String get errorIapNoProductsFound =>
      'Keine Produkte gefunden. Bitte versuche es später erneut.';

  @override
  String errorIapProductLoadError(String details) {
    return 'Fehler beim Laden der Produkte: $details';
  }

  @override
  String get errorIapConnectionError =>
      'Verbindungsfehler. Überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorInitialization =>
      'Fehler bei der Initialisierung der App. Bitte versuche es erneut.';

  @override
  String get errorLoadingRifugi =>
      'Fehler beim Laden der Hütten. Bitte versuche es erneut.';

  @override
  String get errorLoginGeneric => 'Anmeldefehler. Bitte versuche es erneut.';

  @override
  String get filtersTitle => 'Filter & Sortierung';

  @override
  String get resetFilters => 'Filter zurücksetzen';

  @override
  String get sortOrderTitle => 'Sortieren nach';

  @override
  String get sortByDistance => 'Entfernung';

  @override
  String get sortByAltitude => 'Höhe';

  @override
  String get sortByName => 'Name A-Z';

  @override
  String get sortByBeds => 'Schlafplätze';

  @override
  String get filterTypeTitle => 'Hüttentyp';

  @override
  String get typeRifugio => 'Schutzhütte';

  @override
  String get typeBivacco => 'Biwak';

  @override
  String get typeMalga => 'Almhütte';

  @override
  String get filterRegionTitle => 'Region';

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get filterAltitudeTitle => 'Höhe';

  @override
  String get filterServicesTitle => 'Dienste';

  @override
  String get filterWifi => 'WLAN';

  @override
  String get filterRistorante => 'Restaurant';

  @override
  String get filterDocce => 'Duschen';

  @override
  String get filterAcquaCalda => 'Warmwasser';

  @override
  String get filterPos => 'Kartenzahlung';

  @override
  String get filterDefibrillatore => 'Defibrillator';

  @override
  String get filterAccessibilityTitle => 'Zugänglichkeit';

  @override
  String get filterDisabili => 'Barrierefrei';

  @override
  String get filterFamiglie => 'Familien';

  @override
  String get filterAuto => 'Autozugang';

  @override
  String get filterMtb => 'MTB';

  @override
  String get filterAnimali => 'Haustiere';

  @override
  String get filterBedsTitle => 'Mindestschlafplätze';

  @override
  String get filterBedsAny => 'Alle';

  @override
  String get noResultsWithFilters =>
      'Versuche die Filter anzupassen, um Ergebnisse zu finden';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get seasonTheme => 'Jahreszeitenthema';

  @override
  String get seasonAuto => 'Automatisch';

  @override
  String get seasonAutoDesc => 'Folgt der aktuellen Jahreszeit';

  @override
  String get seasonSpring => 'Frühling';

  @override
  String get seasonSummer => 'Sommer';

  @override
  String get seasonAutumn => 'Herbst';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get themeMode => 'Themenmodus';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';
}
