// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mountain Shelters';

  @override
  String get tabList => 'List';

  @override
  String get tabMap => 'Map';

  @override
  String get tabProfile => 'Profile';

  @override
  String get searchHint => 'Search shelters...';

  @override
  String get loadingRifugi => 'Loading shelters...';

  @override
  String get syncingFirebase => 'Syncing with Firebase...';

  @override
  String get error => 'Error';

  @override
  String get noFavoriteRifugi => 'No favorite shelters';

  @override
  String get noRifugiFound => 'No shelters found';

  @override
  String get addFavoritesHint => 'Add some shelters to your favorites';

  @override
  String get modifySearchHint => 'Try modifying your search';

  @override
  String get likeThisApp => 'Enjoying this app?';

  @override
  String get supportDevelopment => 'Support development';

  @override
  String get settings => 'Settings';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get information => 'Information';

  @override
  String get appDescription => 'Mountain Shelters - App for hikers';

  @override
  String get appAboutDescription =>
      'App to explore mountain shelters and bivouacs in the Italian Alps. Use the map to find shelters near you or search by name.';

  @override
  String get privacyAndPermissions => 'Privacy & Permissions';

  @override
  String get locationPermissions => 'Location permissions';

  @override
  String get locationPermissionsDesc => 'Manage location access permissions';

  @override
  String get locationPermissionsDialog =>
      'The app needs access to your location to show nearby shelters on the map. You can change permissions in system settings.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyDesc => 'Your location is not stored';

  @override
  String get privacyDialog =>
      'This app does not store or share your location. Location data is only used to center the map on your current position.';

  @override
  String get help => 'Help';

  @override
  String get reviewOnboarding => 'Review introduction';

  @override
  String get reviewOnboardingDesc => 'Watch the initial onboarding again';

  @override
  String get supportProject => 'Support the Project';

  @override
  String get supportUs => 'Support us';

  @override
  String get supportUsDesc => 'Make a donation to support development';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get rateAppDesc => 'Leave a review on the store';

  @override
  String get rateAppThanks => 'Thanks for your support!';

  @override
  String get rateAppNotAvailable => 'Rating not available on this device';

  @override
  String get madeWithLove => 'Made with ❤️ for mountain lovers';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get showAll => 'Show all';

  @override
  String get onlyFavorites => 'Favorites only';

  @override
  String get profile => 'Profile';

  @override
  String get rifugio => 'Shelter';

  @override
  String get bivacco => 'Bivouac';

  @override
  String get malga => 'Alpine hut';

  @override
  String get altitude => 'Altitude';

  @override
  String altitudeValue(int meters) {
    return '$meters m a.s.l.';
  }

  @override
  String beds(int count) {
    return '$count beds';
  }

  @override
  String bedsShort(int count) {
    return '$count beds';
  }

  @override
  String get locality => 'Locality';

  @override
  String get municipality => 'Municipality';

  @override
  String get valley => 'Valley';

  @override
  String get region => 'Region';

  @override
  String get buildYear => 'Year built';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get position => 'Position';

  @override
  String get informazioni => 'Information';

  @override
  String get services => 'Services';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get management => 'Management';

  @override
  String get contacts => 'Contacts';

  @override
  String get manager => 'Manager';

  @override
  String get property => 'Property';

  @override
  String get type => 'Type';

  @override
  String get restaurant => 'Restaurant';

  @override
  String restaurantWithSeats(int seats) {
    return 'Restaurant ($seats seats)';
  }

  @override
  String get wifi => 'WiFi';

  @override
  String get electricity => 'Electricity';

  @override
  String get pos => 'POS';

  @override
  String get defibrillator => 'Defibrillator';

  @override
  String get hotWater => 'Hot water';

  @override
  String get showers => 'Showers';

  @override
  String get insideWater => 'Indoor water';

  @override
  String get car => 'Car';

  @override
  String get mtb => 'MTB';

  @override
  String get disabled => 'Disabled access';

  @override
  String get disabledWc => 'Disabled WC';

  @override
  String get families => 'Families';

  @override
  String get pets => 'Pets';

  @override
  String get website => 'Website';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get checkIn => 'Check in';

  @override
  String get checkInAgain => 'Check in again';

  @override
  String get checkInProgress => 'Checking in...';

  @override
  String get checkInDone => 'Check-in done!';

  @override
  String get checkInRadius => 'You must be within 100 meters of the shelter';

  @override
  String get checkInAlreadyToday =>
      'You already checked in today! Come back tomorrow to log a new visit.';

  @override
  String get visitedOnce => 'You visited this shelter!';

  @override
  String visitedMultiple(int count) {
    return 'You visited this shelter $count times!';
  }

  @override
  String firstVisit(String date) {
    return 'First visit: $date';
  }

  @override
  String lastVisit(String date) {
    return 'Last visit: $date';
  }

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get shareCheckIn =>
      'Would you like to share your check-in on social media?';

  @override
  String visitNumber(int number) {
    return 'Visit #$number';
  }

  @override
  String get firstTimeWelcome => 'Welcome for the first time to this shelter!';

  @override
  String congratsVisit(int count) {
    return 'Congratulations! This is your visit number $count to this shelter! 🎉';
  }

  @override
  String shareError(String error) {
    return 'Sharing error: $error';
  }

  @override
  String get imageGenerationError => 'Error generating image';

  @override
  String get passaportoTitle => 'My Passport';

  @override
  String get passaportoRifugi => 'Shelter Passport';

  @override
  String get loginRequired => 'You must log in to access the passport';

  @override
  String nRifugi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelters',
      one: '1 shelter',
    );
    return '$_temp0';
  }

  @override
  String get donations => 'Donations';

  @override
  String get donationThanks => 'Thanks for your support! ❤️';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome to Mountain Shelters';

  @override
  String get onboardingWelcomeDesc =>
      'Discover thousands of shelters, bivouacs and alpine huts in the Italian Alps. Plan your mountain excursions with ease.';

  @override
  String get onboardingSearchTitle => 'Search and Find';

  @override
  String get onboardingSearchDesc =>
      'Search shelters by name, area or altitude. Filter results to find the perfect shelter for your adventure.';

  @override
  String get onboardingMapTitle => 'View on the Map';

  @override
  String get onboardingMapDesc =>
      'Explore shelters on the interactive map. View their location and get directions.';

  @override
  String get onboardingAccountTitle => 'Optional Account';

  @override
  String get onboardingAccountDesc =>
      'Sign in with Google or Apple to save your favorite shelters and sync across devices. Or continue without an account.';

  @override
  String get onboardingLocationTitle => 'Location Permission';

  @override
  String get onboardingLocationDesc =>
      'To show you the nearest shelters and provide directions, we need access to your location.';

  @override
  String get legendRifugi => 'Shelters';

  @override
  String get legendBivacchi => 'Bivouacs';

  @override
  String get legendMalghe => 'Alpine huts';

  @override
  String nRifugiInArea(int count) {
    return '$count shelters in this area';
  }

  @override
  String get tapToExpand => 'Tap to expand';

  @override
  String get offlineMap => 'Offline Map';

  @override
  String get offlineMapDesc => 'OpenStreetMap available without connection';

  @override
  String get mapGoogle => 'Google Maps';

  @override
  String get mapOffline => 'Offline Map';

  @override
  String get myItineraries => 'My Itineraries';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get logout => 'Log out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get language => 'Language';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Do you want to sign out of your account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDeleteAccount => 'Delete Account';

  @override
  String get confirmDeleteAccountMessage =>
      'Are you sure you want to delete your account? This action is irreversible and you will lose all your data.';

  @override
  String get delete => 'Delete';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get loginToAccount => 'Sign in to your account';

  @override
  String get loginDescription =>
      'Sign in to save your favorite shelters, track your visits and sync data across devices.';

  @override
  String get continueWithGoogle => 'Sign in with Google';

  @override
  String get continueWithApple => 'Sign in with Apple';

  @override
  String get continueWithoutAccount =>
      'You can continue using the app without signing in.';

  @override
  String get continueWithoutAccountOnboarding => 'Continue without account';

  @override
  String get continueWithGoogleOnboarding => 'Continue with Google';

  @override
  String get continueWithAppleOnboarding => 'Continue with Apple';

  @override
  String get rifugiPreferiti => 'Favorite Shelters';

  @override
  String nRifugiVisitati(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelters visited',
      one: '1 shelter visited',
    );
    return '$_temp0';
  }

  @override
  String get noPreferiti =>
      'No favorite shelters.\nAdd your favorites from the list!';

  @override
  String andOthers(int count) {
    return 'and $count more...';
  }

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionDeniedMessage =>
      'Location permission has been permanently denied. You can enable it manually from device settings.';

  @override
  String get continueWithoutPermission => 'Continue without permission';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionDeniedSnack =>
      'Permission denied. You can grant it later from settings.';

  @override
  String get supportDevelopmentTitle => 'Support Development';

  @override
  String get supportDevelopmentDescription =>
      'If you like this app and want to support development, consider making a donation!';

  @override
  String get donationsInApp => 'In-App Donations';

  @override
  String get donationsNotAvailableNote =>
      'Note: During development, donations may not be available. The app works anyway!';

  @override
  String get inAppPurchasesNotAvailable => 'In-app purchases are not available';

  @override
  String get whyDonate => 'Why donate?';

  @override
  String get regularUpdates => 'Regular updates';

  @override
  String get regularUpdatesDesc => 'New features and continuous improvements';

  @override
  String get moreRifugi => 'More shelters';

  @override
  String get moreRifugiDesc => 'Expanding the database with new shelters';

  @override
  String get supportAndBugfix => 'Support and bug fixes';

  @override
  String get supportAndBugfixDesc => 'Quick resolution of issues and bugs';

  @override
  String get newFeatures => 'New features';

  @override
  String get newFeaturesDesc =>
      'Development of features requested by the community';

  @override
  String get donationOptions => 'Donation options';

  @override
  String get buyCoffee => 'Buy me a coffee';

  @override
  String get buyLunch => 'Buy me a lunch';

  @override
  String get generousDonation => 'Generous donation';

  @override
  String get donation => 'Donation';

  @override
  String get notAvailable => 'Not available';

  @override
  String get donationsInfo =>
      'Donations are one-time payments and do not involve subscriptions.';

  @override
  String get thanksSupport => 'Thanks for your support! 🏔️';

  @override
  String purchaseError(String error) {
    return 'Error: $error';
  }

  @override
  String get cannotStartPurchase => 'Unable to start purchase';

  @override
  String get passaportoEmpty => 'No stamps yet';

  @override
  String get passaportoEmptyDesc =>
      'Visit shelters and check in to collect your stamps!';

  @override
  String get sharePassaporto => 'Share my passport';

  @override
  String get rifugioNotFound => 'Shelter not found';

  @override
  String get nearRifugioRequired =>
      'You must be near the shelter (within 100 meters) to check in';

  @override
  String checkInShareText(String name, int count) {
    return '🏔️ Check-in at $name!\nVisit no. $count\n#RifugiEBivacchi #Mountains #Trekking';
  }

  @override
  String get meteo => 'Weather';

  @override
  String get refresh => 'Refresh';

  @override
  String get nextDays => 'Next days';

  @override
  String get today => 'Today';

  @override
  String get dataOpenMeteo => 'Open-Meteo data';

  @override
  String nRifugiInAreaCount(int count) {
    return '$count shelters in this area';
  }

  @override
  String bedsCount(int count) {
    return '$count beds';
  }

  @override
  String get firebaseInitError =>
      'The app will work anyway, but without authentication.';

  @override
  String get gallery => 'Gallery';

  @override
  String nPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get imageLoadError => 'Unable to load image';
}
