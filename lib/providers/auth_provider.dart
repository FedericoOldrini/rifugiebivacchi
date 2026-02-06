import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    // Ascolta i cambiamenti dello stato di autenticazione
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Login con Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      
      _isLoading = false;
      notifyListeners();
      
      return userCredential != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il login con Google: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Login con Apple
  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signInWithApple();
      
      _isLoading = false;
      notifyListeners();
      
      return userCredential != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il login con Apple: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signOut();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il logout: ${e.toString()}';
      notifyListeners();
    }
  }

  // Elimina account
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.deleteAccount();
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante l\'eliminazione dell\'account: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Verifica se Apple Sign In è disponibile
  Future<bool> isAppleSignInAvailable() async {
    return await _authService.isAppleSignInAvailable();
  }

  // Pulisci errori
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
