import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Verifica se l'onboarding è stato completato
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Verifica se è necessario mostrare l'onboarding
  /// Ritorna true se:
  /// - È il primo avvio (onboarding non completato)
  /// - Oppure il permesso di localizzazione non è stato concesso
  static Future<bool> shouldShowOnboarding() async {
    // Controlla se l'onboarding è stato completato
    final onboardingCompleted = await isOnboardingCompleted();
    
    if (!onboardingCompleted) {
      return true;
    }

    // Se l'onboarding è completato, controlla comunque i permessi
    final locationStatus = await Geolocator.checkPermission();
    
    // Mostra onboarding solo se il permesso è permanentemente negato
    // (per dare all'utente la possibilità di abilitarlo)
    return locationStatus == LocationPermission.deniedForever;
  }

  /// Verifica lo stato del permesso di localizzazione
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Richiede il permesso di localizzazione
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Segna l'onboarding come completato
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Reset dell'onboarding (utile per testing o settings)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }
}
