import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Rifugi e Bivacchi'**
  String get appTitle;

  /// No description provided for @tabList.
  ///
  /// In it, this message translates to:
  /// **'Lista'**
  String get tabList;

  /// No description provided for @tabMap.
  ///
  /// In it, this message translates to:
  /// **'Mappa'**
  String get tabMap;

  /// No description provided for @tabProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get tabProfile;

  /// No description provided for @searchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca rifugi o bivacchi...'**
  String get searchHint;

  /// No description provided for @loadingRifugi.
  ///
  /// In it, this message translates to:
  /// **'Caricamento rifugi...'**
  String get loadingRifugi;

  /// No description provided for @syncingFirebase.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione con Firebase...'**
  String get syncingFirebase;

  /// No description provided for @error.
  ///
  /// In it, this message translates to:
  /// **'Errore'**
  String get error;

  /// No description provided for @noFavoriteRifugi.
  ///
  /// In it, this message translates to:
  /// **'Nessun rifugio preferito'**
  String get noFavoriteRifugi;

  /// No description provided for @noRifugiFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun rifugio trovato'**
  String get noRifugiFound;

  /// No description provided for @addFavoritesHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi dei rifugi ai preferiti'**
  String get addFavoritesHint;

  /// No description provided for @modifySearchHint.
  ///
  /// In it, this message translates to:
  /// **'Prova a modificare la ricerca'**
  String get modifySearchHint;

  /// No description provided for @likeThisApp.
  ///
  /// In it, this message translates to:
  /// **'Ti piace questa app?'**
  String get likeThisApp;

  /// No description provided for @supportDevelopment.
  ///
  /// In it, this message translates to:
  /// **'Supporta lo sviluppo'**
  String get supportDevelopment;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @appInfo.
  ///
  /// In it, this message translates to:
  /// **'Informazioni App'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get version;

  /// No description provided for @information.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get information;

  /// No description provided for @appDescription.
  ///
  /// In it, this message translates to:
  /// **'Rifugi e Bivacchi - App per escursionisti'**
  String get appDescription;

  /// No description provided for @appAboutDescription.
  ///
  /// In it, this message translates to:
  /// **'App per visualizzare rifugi e bivacchi di montagna nelle Alpi italiane. Utilizza la mappa per trovare i rifugi vicino a te o cerca per nome.'**
  String get appAboutDescription;

  /// No description provided for @privacyAndPermissions.
  ///
  /// In it, this message translates to:
  /// **'Privacy e Permessi'**
  String get privacyAndPermissions;

  /// No description provided for @locationPermissions.
  ///
  /// In it, this message translates to:
  /// **'Permessi posizione'**
  String get locationPermissions;

  /// No description provided for @locationPermissionsDesc.
  ///
  /// In it, this message translates to:
  /// **'Gestisci i permessi di accesso alla posizione'**
  String get locationPermissionsDesc;

  /// No description provided for @locationPermissionsDialog.
  ///
  /// In it, this message translates to:
  /// **'L\'app richiede l\'accesso alla tua posizione per mostrarti i rifugi nelle vicinanze sulla mappa. Puoi modificare i permessi nelle impostazioni del sistema.'**
  String get locationPermissionsDialog;

  /// No description provided for @privacy.
  ///
  /// In it, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyDesc.
  ///
  /// In it, this message translates to:
  /// **'La tua posizione non viene memorizzata'**
  String get privacyDesc;

  /// No description provided for @privacyDialog.
  ///
  /// In it, this message translates to:
  /// **'Questa app non memorizza né condivide la tua posizione. I dati di localizzazione vengono utilizzati solo per mostrare la mappa centrata sulla tua posizione corrente.'**
  String get privacyDialog;

  /// No description provided for @help.
  ///
  /// In it, this message translates to:
  /// **'Aiuto'**
  String get help;

  /// No description provided for @reviewOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Rivedi introduzione'**
  String get reviewOnboarding;

  /// No description provided for @reviewOnboardingDesc.
  ///
  /// In it, this message translates to:
  /// **'Visualizza di nuovo l\'onboarding iniziale'**
  String get reviewOnboardingDesc;

  /// No description provided for @supportProject.
  ///
  /// In it, this message translates to:
  /// **'Supporta il Progetto'**
  String get supportProject;

  /// No description provided for @supportUs.
  ///
  /// In it, this message translates to:
  /// **'Supportaci'**
  String get supportUs;

  /// No description provided for @supportUsDesc.
  ///
  /// In it, this message translates to:
  /// **'Fai una donazione per supportare lo sviluppo'**
  String get supportUsDesc;

  /// No description provided for @rateApp.
  ///
  /// In it, this message translates to:
  /// **'Valuta l\'app'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In it, this message translates to:
  /// **'Lascia una recensione sullo store'**
  String get rateAppDesc;

  /// No description provided for @rateAppThanks.
  ///
  /// In it, this message translates to:
  /// **'Grazie per il tuo supporto!'**
  String get rateAppThanks;

  /// No description provided for @rateAppNotAvailable.
  ///
  /// In it, this message translates to:
  /// **'Valutazione non disponibile su questo dispositivo'**
  String get rateAppNotAvailable;

  /// No description provided for @madeWithLove.
  ///
  /// In it, this message translates to:
  /// **'Made with ❤️ for mountain lovers'**
  String get madeWithLove;

  /// No description provided for @ok.
  ///
  /// In it, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @share.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get share;

  /// No description provided for @showAll.
  ///
  /// In it, this message translates to:
  /// **'Mostra tutti'**
  String get showAll;

  /// No description provided for @onlyFavorites.
  ///
  /// In it, this message translates to:
  /// **'Solo preferiti'**
  String get onlyFavorites;

  /// No description provided for @profile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profile;

  /// No description provided for @rifugio.
  ///
  /// In it, this message translates to:
  /// **'Rifugio'**
  String get rifugio;

  /// No description provided for @bivacco.
  ///
  /// In it, this message translates to:
  /// **'Bivacco'**
  String get bivacco;

  /// No description provided for @malga.
  ///
  /// In it, this message translates to:
  /// **'Malga'**
  String get malga;

  /// No description provided for @altitude.
  ///
  /// In it, this message translates to:
  /// **'Altitudine'**
  String get altitude;

  /// No description provided for @altitudeValue.
  ///
  /// In it, this message translates to:
  /// **'{meters} m s.l.m.'**
  String altitudeValue(int meters);

  /// No description provided for @beds.
  ///
  /// In it, this message translates to:
  /// **'{count} posti letto'**
  String beds(int count);

  /// No description provided for @bedsShort.
  ///
  /// In it, this message translates to:
  /// **'{count} posti'**
  String bedsShort(int count);

  /// No description provided for @locality.
  ///
  /// In it, this message translates to:
  /// **'Località'**
  String get locality;

  /// No description provided for @municipality.
  ///
  /// In it, this message translates to:
  /// **'Comune'**
  String get municipality;

  /// No description provided for @valley.
  ///
  /// In it, this message translates to:
  /// **'Valle'**
  String get valley;

  /// No description provided for @region.
  ///
  /// In it, this message translates to:
  /// **'Regione'**
  String get region;

  /// No description provided for @buildYear.
  ///
  /// In it, this message translates to:
  /// **'Anno di costruzione'**
  String get buildYear;

  /// No description provided for @coordinates.
  ///
  /// In it, this message translates to:
  /// **'Coordinate'**
  String get coordinates;

  /// No description provided for @position.
  ///
  /// In it, this message translates to:
  /// **'Posizione'**
  String get position;

  /// No description provided for @informazioni.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get informazioni;

  /// No description provided for @services.
  ///
  /// In it, this message translates to:
  /// **'Servizi'**
  String get services;

  /// No description provided for @accessibility.
  ///
  /// In it, this message translates to:
  /// **'Accessibilità'**
  String get accessibility;

  /// No description provided for @management.
  ///
  /// In it, this message translates to:
  /// **'Gestione'**
  String get management;

  /// No description provided for @contacts.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get contacts;

  /// No description provided for @manager.
  ///
  /// In it, this message translates to:
  /// **'Gestore'**
  String get manager;

  /// No description provided for @property.
  ///
  /// In it, this message translates to:
  /// **'Proprietà'**
  String get property;

  /// No description provided for @type.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @restaurant.
  ///
  /// In it, this message translates to:
  /// **'Ristorante'**
  String get restaurant;

  /// No description provided for @restaurantWithSeats.
  ///
  /// In it, this message translates to:
  /// **'Ristorante ({seats} posti)'**
  String restaurantWithSeats(int seats);

  /// No description provided for @wifi.
  ///
  /// In it, this message translates to:
  /// **'WiFi'**
  String get wifi;

  /// No description provided for @electricity.
  ///
  /// In it, this message translates to:
  /// **'Elettricità'**
  String get electricity;

  /// No description provided for @pos.
  ///
  /// In it, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @defibrillator.
  ///
  /// In it, this message translates to:
  /// **'Defibrillatore'**
  String get defibrillator;

  /// No description provided for @hotWater.
  ///
  /// In it, this message translates to:
  /// **'Acqua calda'**
  String get hotWater;

  /// No description provided for @showers.
  ///
  /// In it, this message translates to:
  /// **'Docce'**
  String get showers;

  /// No description provided for @insideWater.
  ///
  /// In it, this message translates to:
  /// **'Acqua interna'**
  String get insideWater;

  /// No description provided for @car.
  ///
  /// In it, this message translates to:
  /// **'Auto'**
  String get car;

  /// No description provided for @mtb.
  ///
  /// In it, this message translates to:
  /// **'MTB'**
  String get mtb;

  /// No description provided for @disabled.
  ///
  /// In it, this message translates to:
  /// **'Disabili'**
  String get disabled;

  /// No description provided for @disabledWc.
  ///
  /// In it, this message translates to:
  /// **'WC disabili'**
  String get disabledWc;

  /// No description provided for @families.
  ///
  /// In it, this message translates to:
  /// **'Famiglie'**
  String get families;

  /// No description provided for @pets.
  ///
  /// In it, this message translates to:
  /// **'Animali'**
  String get pets;

  /// No description provided for @website.
  ///
  /// In it, this message translates to:
  /// **'Sito web'**
  String get website;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In it, this message translates to:
  /// **'Apri in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @checkIn.
  ///
  /// In it, this message translates to:
  /// **'Fai Check-in'**
  String get checkIn;

  /// No description provided for @checkInAgain.
  ///
  /// In it, this message translates to:
  /// **'Fai Check-in di nuovo'**
  String get checkInAgain;

  /// No description provided for @checkInProgress.
  ///
  /// In it, this message translates to:
  /// **'Check-in in corso...'**
  String get checkInProgress;

  /// No description provided for @checkInDone.
  ///
  /// In it, this message translates to:
  /// **'Check-in effettuato!'**
  String get checkInDone;

  /// No description provided for @checkInRadius.
  ///
  /// In it, this message translates to:
  /// **'Devi essere nel raggio di 100 metri dal rifugio'**
  String get checkInRadius;

  /// No description provided for @checkInAlreadyToday.
  ///
  /// In it, this message translates to:
  /// **'Hai già fatto check-in oggi! Torna domani per registrare una nuova visita.'**
  String get checkInAlreadyToday;

  /// No description provided for @visitedOnce.
  ///
  /// In it, this message translates to:
  /// **'Hai visitato questo rifugio!'**
  String get visitedOnce;

  /// No description provided for @visitedMultiple.
  ///
  /// In it, this message translates to:
  /// **'Hai visitato questo rifugio {count} volte!'**
  String visitedMultiple(int count);

  /// No description provided for @firstVisit.
  ///
  /// In it, this message translates to:
  /// **'Prima visita: {date}'**
  String firstVisit(String date);

  /// No description provided for @lastVisit.
  ///
  /// In it, this message translates to:
  /// **'Ultima visita: {date}'**
  String lastVisit(String date);

  /// No description provided for @removedFromFavorites.
  ///
  /// In it, this message translates to:
  /// **'Rimosso dai preferiti'**
  String get removedFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In it, this message translates to:
  /// **'Aggiunto ai preferiti'**
  String get addedToFavorites;

  /// No description provided for @shareCheckIn.
  ///
  /// In it, this message translates to:
  /// **'Vuoi condividere il tuo check-in sui social?'**
  String get shareCheckIn;

  /// No description provided for @visitNumber.
  ///
  /// In it, this message translates to:
  /// **'Visita n. {number}'**
  String visitNumber(int number);

  /// No description provided for @firstTimeWelcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto per la prima volta in questo rifugio!'**
  String get firstTimeWelcome;

  /// No description provided for @congratsVisit.
  ///
  /// In it, this message translates to:
  /// **'Congratulazioni! Questa è la tua visita numero {count} a questo rifugio! 🎉'**
  String congratsVisit(int count);

  /// No description provided for @shareError.
  ///
  /// In it, this message translates to:
  /// **'Errore nella condivisione: {error}'**
  String shareError(String error);

  /// No description provided for @imageGenerationError.
  ///
  /// In it, this message translates to:
  /// **'Errore nella generazione dell\'immagine'**
  String get imageGenerationError;

  /// No description provided for @passaportoTitle.
  ///
  /// In it, this message translates to:
  /// **'Il Mio Passaporto'**
  String get passaportoTitle;

  /// No description provided for @passaportoRifugi.
  ///
  /// In it, this message translates to:
  /// **'Passaporto dei Rifugi'**
  String get passaportoRifugi;

  /// No description provided for @loginRequired.
  ///
  /// In it, this message translates to:
  /// **'Devi effettuare il login per accedere al passaporto'**
  String get loginRequired;

  /// No description provided for @nRifugi.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 rifugio} other{{count} rifugi}}'**
  String nRifugi(int count);

  /// No description provided for @donations.
  ///
  /// In it, this message translates to:
  /// **'Donazioni'**
  String get donations;

  /// No description provided for @donationThanks.
  ///
  /// In it, this message translates to:
  /// **'Grazie per il tuo supporto! ❤️'**
  String get donationThanks;

  /// No description provided for @errorLabel.
  ///
  /// In it, this message translates to:
  /// **'Errore: {error}'**
  String errorLabel(String error);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in Rifugi e Bivacchi'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In it, this message translates to:
  /// **'Scopri migliaia di rifugi, bivacchi e malghe nelle Alpi italiane. Pianifica le tue escursioni in montagna con facilità.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingSearchTitle.
  ///
  /// In it, this message translates to:
  /// **'Cerca e Trova'**
  String get onboardingSearchTitle;

  /// No description provided for @onboardingSearchDesc.
  ///
  /// In it, this message translates to:
  /// **'Cerca rifugi per nome, zona o altitudine. Filtra i risultati per trovare il rifugio perfetto per la tua avventura.'**
  String get onboardingSearchDesc;

  /// No description provided for @onboardingMapTitle.
  ///
  /// In it, this message translates to:
  /// **'Visualizza sulla Mappa'**
  String get onboardingMapTitle;

  /// No description provided for @onboardingMapDesc.
  ///
  /// In it, this message translates to:
  /// **'Esplora i rifugi sulla mappa interattiva. Visualizza la loro posizione e ottieni indicazioni stradali.'**
  String get onboardingMapDesc;

  /// No description provided for @onboardingAccountTitle.
  ///
  /// In it, this message translates to:
  /// **'Account Opzionale'**
  String get onboardingAccountTitle;

  /// No description provided for @onboardingAccountDesc.
  ///
  /// In it, this message translates to:
  /// **'Accedi con Google o Apple per salvare i tuoi rifugi preferiti e sincronizzarli tra dispositivi. Oppure continua senza account.'**
  String get onboardingAccountDesc;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In it, this message translates to:
  /// **'Permesso Localizzazione'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationDesc.
  ///
  /// In it, this message translates to:
  /// **'Per mostrarti i rifugi più vicini e fornirti indicazioni, abbiamo bisogno di accedere alla tua posizione.'**
  String get onboardingLocationDesc;

  /// No description provided for @legendRifugi.
  ///
  /// In it, this message translates to:
  /// **'Rifugi'**
  String get legendRifugi;

  /// No description provided for @legendBivacchi.
  ///
  /// In it, this message translates to:
  /// **'Bivacchi'**
  String get legendBivacchi;

  /// No description provided for @legendMalghe.
  ///
  /// In it, this message translates to:
  /// **'Malghe'**
  String get legendMalghe;

  /// No description provided for @nRifugiInArea.
  ///
  /// In it, this message translates to:
  /// **'{count} rifugi in questa zona'**
  String nRifugiInArea(int count);

  /// No description provided for @tapToExpand.
  ///
  /// In it, this message translates to:
  /// **'Tocca per espandere'**
  String get tapToExpand;

  /// No description provided for @offlineMap.
  ///
  /// In it, this message translates to:
  /// **'Mappa Offline'**
  String get offlineMap;

  /// No description provided for @offlineMapDesc.
  ///
  /// In it, this message translates to:
  /// **'Mappa OpenStreetMap disponibile anche senza connessione'**
  String get offlineMapDesc;

  /// No description provided for @mapGoogle.
  ///
  /// In it, this message translates to:
  /// **'Google Maps'**
  String get mapGoogle;

  /// No description provided for @mapOffline.
  ///
  /// In it, this message translates to:
  /// **'Mappa Offline'**
  String get mapOffline;

  /// No description provided for @myItineraries.
  ///
  /// In it, this message translates to:
  /// **'I Miei Itinerari'**
  String get myItineraries;

  /// No description provided for @comingSoon.
  ///
  /// In it, this message translates to:
  /// **'Prossimamente disponibile'**
  String get comingSoon;

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In it, this message translates to:
  /// **'Elimina Account'**
  String get deleteAccount;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @confirmLogout.
  ///
  /// In it, this message translates to:
  /// **'Conferma Logout'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In it, this message translates to:
  /// **'Vuoi disconnetterti dal tuo account?'**
  String get confirmLogoutMessage;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In it, this message translates to:
  /// **'Elimina Account'**
  String get confirmDeleteAccount;

  /// No description provided for @confirmDeleteAccountMessage.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile e perderai tutti i tuoi dati.'**
  String get confirmDeleteAccountMessage;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @accountDeleted.
  ///
  /// In it, this message translates to:
  /// **'Account eliminato con successo'**
  String get accountDeleted;

  /// No description provided for @loginToAccount.
  ///
  /// In it, this message translates to:
  /// **'Accedi al tuo account'**
  String get loginToAccount;

  /// No description provided for @loginDescription.
  ///
  /// In it, this message translates to:
  /// **'Accedi per salvare i tuoi rifugi preferiti, tenere traccia delle tue visite e sincronizzare i dati tra dispositivi.'**
  String get loginDescription;

  /// No description provided for @continueWithGoogle.
  ///
  /// In it, this message translates to:
  /// **'Accedi con Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In it, this message translates to:
  /// **'Accedi con Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In it, this message translates to:
  /// **'Puoi continuare ad usare l\'app anche senza effettuare il login.'**
  String get continueWithoutAccount;

  /// No description provided for @continueWithoutAccountOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Continua senza account'**
  String get continueWithoutAccountOnboarding;

  /// No description provided for @continueWithGoogleOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Continua con Google'**
  String get continueWithGoogleOnboarding;

  /// No description provided for @continueWithAppleOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Continua con Apple'**
  String get continueWithAppleOnboarding;

  /// No description provided for @rifugiPreferiti.
  ///
  /// In it, this message translates to:
  /// **'Rifugi Preferiti'**
  String get rifugiPreferiti;

  /// No description provided for @nRifugiVisitati.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 rifugio visitato} other{{count} rifugi visitati}}'**
  String nRifugiVisitati(int count);

  /// No description provided for @noPreferiti.
  ///
  /// In it, this message translates to:
  /// **'Nessun rifugio preferito.\nAggiungi i tuoi preferiti dalla lista!'**
  String get noPreferiti;

  /// No description provided for @andOthers.
  ///
  /// In it, this message translates to:
  /// **'e altri {count}...'**
  String andOthers(int count);

  /// No description provided for @skip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get next;

  /// No description provided for @allowLocation.
  ///
  /// In it, this message translates to:
  /// **'Consenti Posizione'**
  String get allowLocation;

  /// No description provided for @permissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso Negato'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In it, this message translates to:
  /// **'Il permesso di localizzazione è stato negato permanentemente. Puoi abilitarlo manualmente dalle impostazioni del dispositivo.'**
  String get permissionDeniedMessage;

  /// No description provided for @continueWithoutPermission.
  ///
  /// In it, this message translates to:
  /// **'Continua senza permesso'**
  String get continueWithoutPermission;

  /// No description provided for @openSettings.
  ///
  /// In it, this message translates to:
  /// **'Apri Impostazioni'**
  String get openSettings;

  /// No description provided for @permissionDeniedSnack.
  ///
  /// In it, this message translates to:
  /// **'Permesso negato. Puoi concederlo in seguito dalle impostazioni.'**
  String get permissionDeniedSnack;

  /// No description provided for @supportDevelopmentTitle.
  ///
  /// In it, this message translates to:
  /// **'Supporta lo Sviluppo'**
  String get supportDevelopmentTitle;

  /// No description provided for @supportDevelopmentDescription.
  ///
  /// In it, this message translates to:
  /// **'Se ti piace questa app e vuoi supportare lo sviluppo, considera di fare una donazione!'**
  String get supportDevelopmentDescription;

  /// No description provided for @donationsInApp.
  ///
  /// In it, this message translates to:
  /// **'Donazioni In-App'**
  String get donationsInApp;

  /// No description provided for @donationsNotAvailableNote.
  ///
  /// In it, this message translates to:
  /// **'Nota: Durante lo sviluppo, le donazioni potrebbero non essere disponibili. L\'app funziona comunque!'**
  String get donationsNotAvailableNote;

  /// No description provided for @inAppPurchasesNotAvailable.
  ///
  /// In it, this message translates to:
  /// **'Gli acquisti in-app non sono disponibili'**
  String get inAppPurchasesNotAvailable;

  /// No description provided for @whyDonate.
  ///
  /// In it, this message translates to:
  /// **'Perché donare?'**
  String get whyDonate;

  /// No description provided for @regularUpdates.
  ///
  /// In it, this message translates to:
  /// **'Aggiornamenti regolari'**
  String get regularUpdates;

  /// No description provided for @regularUpdatesDesc.
  ///
  /// In it, this message translates to:
  /// **'Nuove funzionalità e miglioramenti continui'**
  String get regularUpdatesDesc;

  /// No description provided for @moreRifugi.
  ///
  /// In it, this message translates to:
  /// **'Più rifugi'**
  String get moreRifugi;

  /// No description provided for @moreRifugiDesc.
  ///
  /// In it, this message translates to:
  /// **'Espansione del database con nuovi rifugi'**
  String get moreRifugiDesc;

  /// No description provided for @supportAndBugfix.
  ///
  /// In it, this message translates to:
  /// **'Supporto e bug fix'**
  String get supportAndBugfix;

  /// No description provided for @supportAndBugfixDesc.
  ///
  /// In it, this message translates to:
  /// **'Risoluzione rapida di problemi e bug'**
  String get supportAndBugfixDesc;

  /// No description provided for @newFeatures.
  ///
  /// In it, this message translates to:
  /// **'Nuove funzionalità'**
  String get newFeatures;

  /// No description provided for @newFeaturesDesc.
  ///
  /// In it, this message translates to:
  /// **'Sviluppo di features richieste dalla community'**
  String get newFeaturesDesc;

  /// No description provided for @donationOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni di donazione'**
  String get donationOptions;

  /// No description provided for @buyCoffee.
  ///
  /// In it, this message translates to:
  /// **'Offrimi un caffè'**
  String get buyCoffee;

  /// No description provided for @buyLunch.
  ///
  /// In it, this message translates to:
  /// **'Offrimi un pranzo'**
  String get buyLunch;

  /// No description provided for @generousDonation.
  ///
  /// In it, this message translates to:
  /// **'Donazione generosa'**
  String get generousDonation;

  /// No description provided for @donation.
  ///
  /// In it, this message translates to:
  /// **'Donazione'**
  String get donation;

  /// No description provided for @notAvailable.
  ///
  /// In it, this message translates to:
  /// **'Non disponibile'**
  String get notAvailable;

  /// No description provided for @donationsInfo.
  ///
  /// In it, this message translates to:
  /// **'Le donazioni sono pagamenti una tantum e non comportano abbonamenti.'**
  String get donationsInfo;

  /// No description provided for @thanksSupport.
  ///
  /// In it, this message translates to:
  /// **'Grazie per il tuo supporto! 🏔️'**
  String get thanksSupport;

  /// No description provided for @purchaseError.
  ///
  /// In it, this message translates to:
  /// **'Errore: {error}'**
  String purchaseError(String error);

  /// No description provided for @cannotStartPurchase.
  ///
  /// In it, this message translates to:
  /// **'Impossibile avviare l\'acquisto'**
  String get cannotStartPurchase;

  /// No description provided for @passaportoEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun timbro ancora'**
  String get passaportoEmpty;

  /// No description provided for @passaportoEmptyDesc.
  ///
  /// In it, this message translates to:
  /// **'Visita i rifugi e fai check-in per collezionare i tuoi timbri!'**
  String get passaportoEmptyDesc;

  /// No description provided for @sharePassaporto.
  ///
  /// In it, this message translates to:
  /// **'Condividi il mio passaporto'**
  String get sharePassaporto;

  /// No description provided for @rifugioNotFound.
  ///
  /// In it, this message translates to:
  /// **'Rifugio non trovato'**
  String get rifugioNotFound;

  /// No description provided for @nearRifugioRequired.
  ///
  /// In it, this message translates to:
  /// **'Devi essere vicino al rifugio (entro 100 metri) per fare check-in'**
  String get nearRifugioRequired;

  /// No description provided for @checkInShareText.
  ///
  /// In it, this message translates to:
  /// **'🏔️ Check-in al {name}!\nVisita n. {count}\n#RifugiEBivacchi #Montagna #Trekking'**
  String checkInShareText(String name, int count);

  /// No description provided for @meteo.
  ///
  /// In it, this message translates to:
  /// **'Meteo'**
  String get meteo;

  /// No description provided for @refresh.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get refresh;

  /// No description provided for @nextDays.
  ///
  /// In it, this message translates to:
  /// **'Prossimi giorni'**
  String get nextDays;

  /// No description provided for @today.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get today;

  /// No description provided for @dataOpenMeteo.
  ///
  /// In it, this message translates to:
  /// **'Dati Open-Meteo'**
  String get dataOpenMeteo;

  /// No description provided for @nRifugiInAreaCount.
  ///
  /// In it, this message translates to:
  /// **'{count} rifugi in questa zona'**
  String nRifugiInAreaCount(int count);

  /// No description provided for @bedsCount.
  ///
  /// In it, this message translates to:
  /// **'{count} posti letto'**
  String bedsCount(int count);

  /// No description provided for @firebaseInitError.
  ///
  /// In it, this message translates to:
  /// **'L\'app funzionerà comunque, ma senza autenticazione.'**
  String get firebaseInitError;

  /// No description provided for @gallery.
  ///
  /// In it, this message translates to:
  /// **'Galleria'**
  String get gallery;

  /// No description provided for @nPhotos.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 foto} other{{count} foto}}'**
  String nPhotos(int count);

  /// No description provided for @imageLoadError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare l\'immagine'**
  String get imageLoadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
