// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Refuges de Montagne';

  @override
  String get tabList => 'Liste';

  @override
  String get tabMap => 'Carte';

  @override
  String get tabProfile => 'Profil';

  @override
  String get searchHint => 'Rechercher des refuges...';

  @override
  String get loadingRifugi => 'Chargement des refuges...';

  @override
  String get syncingFirebase => 'Synchronisation avec Firebase...';

  @override
  String get error => 'Erreur';

  @override
  String get noFavoriteRifugi => 'Aucun refuge favori';

  @override
  String get noRifugiFound => 'Aucun refuge trouvé';

  @override
  String get addFavoritesHint => 'Ajoutez des refuges à vos favoris';

  @override
  String get modifySearchHint => 'Essayez de modifier votre recherche';

  @override
  String get likeThisApp => 'Vous aimez cette app ?';

  @override
  String get supportDevelopment => 'Soutenez le développement';

  @override
  String get settings => 'Paramètres';

  @override
  String get appInfo => 'Info App';

  @override
  String get version => 'Version';

  @override
  String get information => 'Informations';

  @override
  String get appDescription => 'Refuges de Montagne - App pour randonneurs';

  @override
  String get appAboutDescription =>
      'App pour explorer les refuges et bivouacs de montagne dans les Alpes italiennes. Utilisez la carte pour trouver les refuges près de vous ou recherchez par nom.';

  @override
  String get privacyAndPermissions => 'Confidentialité et Autorisations';

  @override
  String get locationPermissions => 'Autorisations de localisation';

  @override
  String get locationPermissionsDesc =>
      'Gérer les autorisations d\'accès à la position';

  @override
  String get locationPermissionsDialog =>
      'L\'app a besoin d\'accéder à votre position pour vous montrer les refuges à proximité sur la carte. Vous pouvez modifier les autorisations dans les paramètres du système.';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacyDesc => 'Votre position n\'est pas enregistrée';

  @override
  String get privacyDialog =>
      'Cette app ne stocke ni ne partage votre position. Les données de localisation sont uniquement utilisées pour centrer la carte sur votre position actuelle.';

  @override
  String get help => 'Aide';

  @override
  String get reviewOnboarding => 'Revoir l\'introduction';

  @override
  String get reviewOnboardingDesc => 'Revoir l\'onboarding initial';

  @override
  String get supportProject => 'Soutenir le Projet';

  @override
  String get supportUs => 'Soutenez-nous';

  @override
  String get supportUsDesc => 'Faites un don pour soutenir le développement';

  @override
  String get rateApp => 'Évaluer l\'app';

  @override
  String get rateAppDesc => 'Laissez un avis sur le store';

  @override
  String get rateAppThanks => 'Merci pour votre soutien !';

  @override
  String get rateAppNotAvailable =>
      'Évaluation non disponible sur cet appareil';

  @override
  String get madeWithLove => 'Made with ❤️ for mountain lovers';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Fermer';

  @override
  String get share => 'Partager';

  @override
  String get showAll => 'Tout afficher';

  @override
  String get onlyFavorites => 'Favoris uniquement';

  @override
  String get profile => 'Profil';

  @override
  String get rifugio => 'Refuge';

  @override
  String get bivacco => 'Bivouac';

  @override
  String get malga => 'Alpage';

  @override
  String get altitude => 'Altitude';

  @override
  String altitudeValue(int meters) {
    return '$meters m d\'alt.';
  }

  @override
  String beds(int count) {
    return '$count couchages';
  }

  @override
  String bedsShort(int count) {
    return '$count places';
  }

  @override
  String get locality => 'Localité';

  @override
  String get municipality => 'Commune';

  @override
  String get valley => 'Vallée';

  @override
  String get region => 'Région';

  @override
  String get buildYear => 'Année de construction';

  @override
  String get coordinates => 'Coordonnées';

  @override
  String get position => 'Position';

  @override
  String get informazioni => 'Informations';

  @override
  String get services => 'Services';

  @override
  String get accessibility => 'Accessibilité';

  @override
  String get management => 'Gestion';

  @override
  String get contacts => 'Contacts';

  @override
  String get manager => 'Gestionnaire';

  @override
  String get property => 'Propriété';

  @override
  String get type => 'Type';

  @override
  String get restaurant => 'Restaurant';

  @override
  String restaurantWithSeats(int seats) {
    return 'Restaurant ($seats places)';
  }

  @override
  String get wifi => 'WiFi';

  @override
  String get electricity => 'Électricité';

  @override
  String get pos => 'Terminal CB';

  @override
  String get defibrillator => 'Défibrillateur';

  @override
  String get hotWater => 'Eau chaude';

  @override
  String get showers => 'Douches';

  @override
  String get insideWater => 'Eau intérieure';

  @override
  String get car => 'Voiture';

  @override
  String get mtb => 'VTT';

  @override
  String get disabled => 'Handicapés';

  @override
  String get disabledWc => 'WC handicapés';

  @override
  String get families => 'Familles';

  @override
  String get pets => 'Animaux';

  @override
  String get website => 'Site web';

  @override
  String get openInGoogleMaps => 'Ouvrir dans Google Maps';

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkInAgain => 'Check-in à nouveau';

  @override
  String get checkInProgress => 'Check-in en cours...';

  @override
  String get checkInDone => 'Check-in effectué !';

  @override
  String get checkInRadius =>
      'Vous devez être dans un rayon de 100 mètres du refuge';

  @override
  String get checkInAlreadyToday =>
      'Vous avez déjà fait le check-in aujourd\'hui ! Revenez demain pour enregistrer une nouvelle visite.';

  @override
  String get visitedOnce => 'Vous avez visité ce refuge !';

  @override
  String visitedMultiple(int count) {
    return 'Vous avez visité ce refuge $count fois !';
  }

  @override
  String firstVisit(String date) {
    return 'Première visite : $date';
  }

  @override
  String lastVisit(String date) {
    return 'Dernière visite : $date';
  }

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get shareCheckIn =>
      'Voulez-vous partager votre check-in sur les réseaux sociaux ?';

  @override
  String visitNumber(int number) {
    return 'Visite n° $number';
  }

  @override
  String get firstTimeWelcome =>
      'Bienvenue pour la première fois dans ce refuge !';

  @override
  String congratsVisit(int count) {
    return 'Félicitations ! C\'est votre visite numéro $count dans ce refuge ! 🎉';
  }

  @override
  String shareError(String error) {
    return 'Erreur de partage : $error';
  }

  @override
  String get imageGenerationError => 'Erreur de génération d\'image';

  @override
  String get passaportoTitle => 'Mon Passeport';

  @override
  String get passaportoRifugi => 'Passeport des Refuges';

  @override
  String get loginRequired =>
      'Vous devez vous connecter pour accéder au passeport';

  @override
  String nRifugi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refuges',
      one: '1 refuge',
    );
    return '$_temp0';
  }

  @override
  String get donations => 'Dons';

  @override
  String get donationThanks => 'Merci pour votre soutien ! ❤️';

  @override
  String errorLabel(String error) {
    return 'Erreur : $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Refuges de Montagne';

  @override
  String get onboardingWelcomeDesc =>
      'Découvrez des milliers de refuges, bivouacs et alpages dans les Alpes italiennes. Planifiez vos excursions en montagne facilement.';

  @override
  String get onboardingSearchTitle => 'Chercher et Trouver';

  @override
  String get onboardingSearchDesc =>
      'Recherchez des refuges par nom, zone ou altitude. Filtrez les résultats pour trouver le refuge parfait pour votre aventure.';

  @override
  String get onboardingMapTitle => 'Voir sur la Carte';

  @override
  String get onboardingMapDesc =>
      'Explorez les refuges sur la carte interactive. Visualisez leur position et obtenez des directions.';

  @override
  String get onboardingAccountTitle => 'Compte Optionnel';

  @override
  String get onboardingAccountDesc =>
      'Connectez-vous avec Google ou Apple pour sauvegarder vos refuges favoris et les synchroniser entre appareils. Ou continuez sans compte.';

  @override
  String get onboardingLocationTitle => 'Autorisation de Localisation';

  @override
  String get onboardingLocationDesc =>
      'Pour vous montrer les refuges les plus proches et vous fournir des directions, nous avons besoin d\'accéder à votre position.';

  @override
  String get legendRifugi => 'Refuges';

  @override
  String get legendBivacchi => 'Bivouacs';

  @override
  String get legendMalghe => 'Alpages';

  @override
  String nRifugiInArea(int count) {
    return '$count refuges dans cette zone';
  }

  @override
  String get tapToExpand => 'Appuyez pour agrandir';

  @override
  String get offlineMap => 'Carte Hors Ligne';

  @override
  String get offlineMapDesc => 'OpenStreetMap disponible sans connexion';

  @override
  String get mapGoogle => 'Google Maps';

  @override
  String get mapOffline => 'Carte Hors Ligne';

  @override
  String get myItineraries => 'Mes Itinéraires';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get logout => 'Déconnexion';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get language => 'Langue';

  @override
  String get confirmLogout => 'Confirmer la déconnexion';

  @override
  String get confirmLogoutMessage =>
      'Voulez-vous vous déconnecter de votre compte ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirmDeleteAccount => 'Supprimer le compte';

  @override
  String get confirmDeleteAccountMessage =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et vous perdrez toutes vos données.';

  @override
  String get delete => 'Supprimer';

  @override
  String get accountDeleted => 'Compte supprimé avec succès';

  @override
  String get loginToAccount => 'Connectez-vous à votre compte';

  @override
  String get loginDescription =>
      'Connectez-vous pour sauvegarder vos refuges préférés, suivre vos visites et synchroniser les données entre appareils.';

  @override
  String get continueWithGoogle => 'Se connecter avec Google';

  @override
  String get continueWithApple => 'Se connecter avec Apple';

  @override
  String get continueWithoutAccount =>
      'Vous pouvez continuer à utiliser l\'application sans vous connecter.';

  @override
  String get continueWithoutAccountOnboarding => 'Continuer sans compte';

  @override
  String get continueWithGoogleOnboarding => 'Continuer avec Google';

  @override
  String get continueWithAppleOnboarding => 'Continuer avec Apple';

  @override
  String get rifugiPreferiti => 'Refuges Préférés';

  @override
  String nRifugiVisitati(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refuges visités',
      one: '1 refuge visité',
    );
    return '$_temp0';
  }

  @override
  String get noPreferiti =>
      'Aucun refuge préféré.\nAjoutez vos favoris depuis la liste !';

  @override
  String andOthers(int count) {
    return 'et $count autres...';
  }

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get allowLocation => 'Autoriser la localisation';

  @override
  String get permissionDenied => 'Permission refusée';

  @override
  String get permissionDeniedMessage =>
      'La permission de localisation a été refusée de manière permanente. Vous pouvez l\'activer manuellement dans les paramètres de l\'appareil.';

  @override
  String get continueWithoutPermission => 'Continuer sans permission';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get permissionDeniedSnack =>
      'Permission refusée. Vous pouvez l\'accorder plus tard dans les paramètres.';

  @override
  String get supportDevelopmentTitle => 'Soutenir le développement';

  @override
  String get supportDevelopmentDescription =>
      'Si vous aimez cette application et souhaitez soutenir le développement, envisagez de faire un don !';

  @override
  String get donationsInApp => 'Dons In-App';

  @override
  String get donationsNotAvailableNote =>
      'Note : Pendant le développement, les dons peuvent ne pas être disponibles. L\'application fonctionne quand même !';

  @override
  String get inAppPurchasesNotAvailable =>
      'Les achats in-app ne sont pas disponibles';

  @override
  String get whyDonate => 'Pourquoi donner ?';

  @override
  String get regularUpdates => 'Mises à jour régulières';

  @override
  String get regularUpdatesDesc =>
      'Nouvelles fonctionnalités et améliorations continues';

  @override
  String get moreRifugi => 'Plus de refuges';

  @override
  String get moreRifugiDesc =>
      'Extension de la base de données avec de nouveaux refuges';

  @override
  String get supportAndBugfix => 'Support et corrections';

  @override
  String get supportAndBugfixDesc =>
      'Résolution rapide des problèmes et des bugs';

  @override
  String get newFeatures => 'Nouvelles fonctionnalités';

  @override
  String get newFeaturesDesc =>
      'Développement de fonctionnalités demandées par la communauté';

  @override
  String get donationOptions => 'Options de don';

  @override
  String get buyCoffee => 'Offrez-moi un café';

  @override
  String get buyLunch => 'Offrez-moi un déjeuner';

  @override
  String get generousDonation => 'Don généreux';

  @override
  String get donation => 'Don';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get donationsInfo =>
      'Les dons sont des paiements uniques et n\'impliquent pas d\'abonnements.';

  @override
  String get thanksSupport => 'Merci pour votre soutien ! 🏔️';

  @override
  String purchaseError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get cannotStartPurchase => 'Impossible de lancer l\'achat';

  @override
  String get passaportoEmpty => 'Pas encore de tampons';

  @override
  String get passaportoEmptyDesc =>
      'Visitez des refuges et faites un check-in pour collecter vos tampons !';

  @override
  String get sharePassaporto => 'Partager mon passeport';

  @override
  String get rifugioNotFound => 'Refuge non trouvé';

  @override
  String get nearRifugioRequired =>
      'Vous devez être près du refuge (dans un rayon de 100 mètres) pour faire un check-in';

  @override
  String checkInShareText(String name, int count) {
    return '🏔️ Check-in au $name !\nVisite n° $count\n#RifugiEBivacchi #Montagne #Randonnée';
  }

  @override
  String get meteo => 'Météo';

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get nextDays => 'Prochains jours';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get dataOpenMeteo => 'Données Open-Meteo';

  @override
  String nRifugiInAreaCount(int count) {
    return '$count refuges dans cette zone';
  }

  @override
  String bedsCount(int count) {
    return '$count lits';
  }

  @override
  String get firebaseInitError =>
      'L\'application fonctionnera quand même, mais sans authentification.';

  @override
  String get gallery => 'Galerie';

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
  String get imageLoadError => 'Impossible de charger l\'image';

  @override
  String get weatherClear => 'Dégagé';

  @override
  String get weatherMostlyClear => 'Plutôt dégagé';

  @override
  String get weatherPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherCloudy => 'Nuageux';

  @override
  String get weatherFog => 'Brouillard';

  @override
  String get weatherDrizzle => 'Bruine';

  @override
  String get weatherLightRain => 'Pluie légère';

  @override
  String get weatherModerateRain => 'Pluie modérée';

  @override
  String get weatherHeavyRain => 'Pluie forte';

  @override
  String get weatherLightSnow => 'Neige légère';

  @override
  String get weatherModerateSnow => 'Neige modérée';

  @override
  String get weatherHeavySnow => 'Neige forte';

  @override
  String get weatherSnowGrains => 'Grains de neige';

  @override
  String get weatherShowers => 'Averses';

  @override
  String get weatherSnowShowers => 'Averses de neige';

  @override
  String get weatherThunderstorm => 'Orage';

  @override
  String get weatherThunderstormHail => 'Orage avec grêle';

  @override
  String get weatherNotAvailable => 'Météo non disponible';

  @override
  String nVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visites',
      one: '1 visite',
    );
    return '$_temp0';
  }

  @override
  String get firstVisitLabel => 'Première visite';

  @override
  String get lastVisitLabel => 'Dernière visite';

  @override
  String get visited => 'VISITÉ';

  @override
  String shareVisitLabel(int count) {
    return 'VISITE N° $count';
  }

  @override
  String get shareCheckInLabel => 'CHECK-IN';

  @override
  String get shareAltitudeUnit => 'm d\'alt.';

  @override
  String get shareHashtags => '#RefugesDeMontagne #Montagne #Randonnée';

  @override
  String shareAltitude(int meters) {
    return '📍 $meters m';
  }

  @override
  String get shareMyPassportTitle => 'MON PASSEPORT';

  @override
  String get shareOfSheltersTitle => 'DES REFUGES';

  @override
  String get shareVisitSingular => 'VISITE';

  @override
  String get shareVisitPlural => 'VISITES';

  @override
  String get shareShelterSingular => 'REFUGE';

  @override
  String get shareShelterPlural => 'REFUGES';

  @override
  String get shareMaxAltitude => 'ALTITUDE MAX';

  @override
  String get shareSheltersVisited => 'REFUGES VISITÉS';

  @override
  String get shareTrueExplorer => 'Vrai Explorateur !';

  @override
  String shareVisitedCount(int count) {
    return 'Vous avez visité $count refuges !';
  }

  @override
  String get sharePassaportoHashtags =>
      '#RefugesDeMontagne #PasseportDesRefuges #Montagne';

  @override
  String sharePassaportoText(int count) {
    return '🏔️ Mon passeport des refuges !\n$count refuges visités\n#RefugesDeMontagne';
  }

  @override
  String get errorIapNotAvailable =>
      'Achats intégrés non disponibles sur cet appareil';

  @override
  String get errorIapProductsNotConfigured =>
      'Produits pas encore configurés. Les dons seront bientôt disponibles.';

  @override
  String get errorIapNoProductsFound =>
      'Aucun produit trouvé. Veuillez réessayer plus tard.';

  @override
  String errorIapProductLoadError(String details) {
    return 'Erreur lors du chargement des produits : $details';
  }

  @override
  String get errorIapConnectionError =>
      'Erreur de connexion. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get errorInitialization =>
      'Erreur lors de l\'initialisation de l\'application. Veuillez réessayer.';

  @override
  String get errorLoadingRifugi =>
      'Erreur lors du chargement des refuges. Veuillez réessayer.';

  @override
  String get errorLoginGeneric => 'Erreur de connexion. Veuillez réessayer.';

  @override
  String get filtersTitle => 'Filtres et Tri';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get sortOrderTitle => 'Trier par';

  @override
  String get sortByDistance => 'Distance';

  @override
  String get sortByAltitude => 'Altitude';

  @override
  String get sortByName => 'Nom A-Z';

  @override
  String get sortByBeds => 'Couchages';

  @override
  String get filterTypeTitle => 'Type de refuge';

  @override
  String get typeRifugio => 'Refuge';

  @override
  String get typeBivacco => 'Bivouac';

  @override
  String get typeMalga => 'Alpage';

  @override
  String get filterRegionTitle => 'Région';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get filterAltitudeTitle => 'Altitude';

  @override
  String get filterServicesTitle => 'Services';

  @override
  String get filterWifi => 'WiFi';

  @override
  String get filterRistorante => 'Restaurant';

  @override
  String get filterDocce => 'Douches';

  @override
  String get filterAcquaCalda => 'Eau chaude';

  @override
  String get filterPos => 'Paiement CB';

  @override
  String get filterDefibrillatore => 'Défibrillateur';

  @override
  String get filterAccessibilityTitle => 'Accessibilité';

  @override
  String get filterDisabili => 'Handicapés';

  @override
  String get filterFamiglie => 'Familles';

  @override
  String get filterAuto => 'Accès voiture';

  @override
  String get filterMtb => 'VTT';

  @override
  String get filterAnimali => 'Animaux';

  @override
  String get filterBedsTitle => 'Couchages minimum';

  @override
  String get filterBedsAny => 'Tous';

  @override
  String get noResultsWithFilters =>
      'Essayez d\'ajuster les filtres pour trouver des résultats';
}
