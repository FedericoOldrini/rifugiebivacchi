import 'package:firebase_analytics/firebase_analytics.dart';

/// Servizio centralizzato per il tracciamento degli eventi Firebase Analytics.
///
/// Fornisce un singleton con metodi tipizzati per ogni evento custom dell'app,
/// oltre all'observer per il tracciamento automatico della navigazione.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Observer per il tracciamento automatico delle schermate nel MaterialApp.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ---------------------------------------------------------------------------
  // Rifugi
  // ---------------------------------------------------------------------------

  /// L'utente visualizza il dettaglio di un rifugio.
  Future<void> logViewRifugio({
    required String rifugioId,
    required String rifugioNome,
    String? tipo,
  }) => _analytics.logEvent(
    name: 'view_rifugio',
    parameters: {
      'rifugio_id': rifugioId,
      'rifugio_nome': rifugioNome,
      if (tipo != null) 'tipo': tipo,
    },
  );

  /// L'utente cerca un rifugio nella lista.
  Future<void> logSearchRifugio({required String query}) =>
      _analytics.logEvent(name: 'search_rifugio', parameters: {'query': query});

  // ---------------------------------------------------------------------------
  // Preferiti
  // ---------------------------------------------------------------------------

  /// L'utente aggiunge o rimuove un rifugio dai preferiti.
  Future<void> logTogglePreferito({
    required String rifugioId,
    required bool aggiunto,
  }) => _analytics.logEvent(
    name: 'toggle_preferito',
    parameters: {'rifugio_id': rifugioId, 'aggiunto': aggiunto.toString()},
  );

  // ---------------------------------------------------------------------------
  // Passaporto (check-in)
  // ---------------------------------------------------------------------------

  /// L'utente registra un check-in al rifugio.
  Future<void> logCheckin({
    required String rifugioId,
    required String rifugioNome,
  }) => _analytics.logEvent(
    name: 'checkin',
    parameters: {'rifugio_id': rifugioId, 'rifugio_nome': rifugioNome},
  );

  /// L'utente condivide la card del check-in.
  Future<void> logShareCheckin({required String rifugioId}) => _analytics
      .logEvent(name: 'share_checkin', parameters: {'rifugio_id': rifugioId});

  // ---------------------------------------------------------------------------
  // Mappa
  // ---------------------------------------------------------------------------

  /// L'utente apre la mappa offline.
  Future<void> logOpenOfflineMap() =>
      _analytics.logEvent(name: 'open_offline_map');

  // ---------------------------------------------------------------------------
  // Autenticazione
  // ---------------------------------------------------------------------------

  /// L'utente effettua il login.
  Future<void> logLogin({required String method}) =>
      _analytics.logLogin(loginMethod: method);

  /// L'utente effettua il logout.
  Future<void> logLogout() => _analytics.logEvent(name: 'logout');

  // ---------------------------------------------------------------------------
  // Donazioni
  // ---------------------------------------------------------------------------

  /// L'utente apre la schermata donazioni.
  Future<void> logOpenDonations() =>
      _analytics.logEvent(name: 'open_donations');

  /// L'utente completa una donazione.
  Future<void> logDonation({required String productId}) => _analytics.logEvent(
    name: 'donation_completed',
    parameters: {'product_id': productId},
  );

  // ---------------------------------------------------------------------------
  // Impostazioni
  // ---------------------------------------------------------------------------

  /// L'utente richiede una review dell'app.
  Future<void> logRateApp() => _analytics.logEvent(name: 'rate_app');

  /// L'utente rivede l'onboarding.
  Future<void> logReviewOnboarding() =>
      _analytics.logEvent(name: 'review_onboarding');
}
