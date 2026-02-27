import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';

class AuthProvider with ChangeNotifier {
  AuthService? _authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Campi per testMode (screenshot)
  final bool _testMode;
  dynamic _fakeUser;

  /// Se [testMode] è `true`, salta Firebase Auth e usa dati fake.
  /// Usato per screenshot automatici e test.
  AuthProvider({bool testMode = false}) : _testMode = testMode {
    if (!testMode) {
      _authService = AuthService();
      // Ascolta i cambiamenti dello stato di autenticazione
      _authService!.authStateChanges.listen((User? user) {
        _user = user;
        notifyListeners();
      });
    }
  }

  /// Inietta un utente fake dall'esterno (per test/screenshot).
  /// Non usare in produzione.
  void setFakeUser({
    required String uid,
    required String displayName,
    required String email,
    String? photoURL,
  }) {
    _fakeUser = _TestUser(
      uid: uid,
      displayName: displayName,
      email: email,
      photoURL: photoURL,
    );
    notifyListeners();
  }

  /// Restituisce l'utente — in testMode restituisce il fake user.
  dynamic get user => _testMode ? _fakeUser : _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => user != null;

  // Login con Google
  Future<bool> signInWithGoogle() async {
    if (_testMode) return true;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService!.signInWithGoogle();

      _isLoading = false;
      notifyListeners();

      if (userCredential != null) {
        AnalyticsService.instance.logLogin(method: 'google');
      }
      return userCredential != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'google_login_error:${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Login con Apple
  Future<bool> signInWithApple() async {
    if (_testMode) return true;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService!.signInWithApple();

      _isLoading = false;
      notifyListeners();

      if (userCredential != null) {
        AnalyticsService.instance.logLogin(method: 'apple');
      }
      return userCredential != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'apple_login_error:${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    if (_testMode) return;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService!.signOut();
      AnalyticsService.instance.logLogout();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'logout_error:${e.toString()}';
      notifyListeners();
    }
  }

  // Elimina account
  Future<bool> deleteAccount() async {
    if (_testMode) return true;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService!.deleteAccount();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'delete_account_error:${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Verifica se Apple Sign In è disponibile
  Future<bool> isAppleSignInAvailable() async {
    if (_testMode) return false;
    return await _authService!.isAppleSignInAvailable();
  }

  // Pulisci errori
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Utente fake per screenshot/test — espone la stessa API di [User].
class _TestUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;

  const _TestUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
  });
}
