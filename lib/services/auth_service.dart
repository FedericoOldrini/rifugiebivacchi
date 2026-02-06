import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  bool _initialized = false;

  // Inizializza Google Sign In (chiamalo una volta all'avvio)
  Future<void> initializeGoogleSignIn() async {
    if (_initialized) return;
    
    await _googleSignIn.initialize();
    _initialized = true;
  }

  // Stream dell'utente corrente
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Ottieni l'utente corrente
  User? get currentUser => _auth.currentUser;

  // Login con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Assicurati che sia inizializzato
      await initializeGoogleSignIn();
      
      // Prova prima un sign in silenzioso, poi interattivo
      GoogleSignInAccount? googleUser = await _googleSignIn.attemptLightweightAuthentication();
      
      if (googleUser == null) {
        // Se il sign in silenzioso fallisce, usa quello interattivo con scopes
        googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      }

      // Se googleUser è ancora null dopo authenticate, l'utente ha annullato
      // ma authenticate potrebbe già lanciare un'eccezione in questo caso

      // Ottieni i dettagli dell'autenticazione (ora è un getter sincrono)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Crea una nuova credenziale (in v7.x solo idToken è disponibile)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Una volta effettuato il login, restituisci UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Errore durante il login con Google: $e');
      rethrow;
    }
  }

  // Login con Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Richiedi le credenziali Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Crea una credenziale OAuth
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Effettua il login con Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Aggiorna il display name se disponibile
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
        }
      }

      return userCredential;
    } catch (e) {
      print('Errore durante il login con Apple: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Errore durante il logout: $e');
      rethrow;
    }
  }

  // Elimina account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'account: $e');
      rethrow;
    }
  }

  // Verifica se Apple Sign In è disponibile
  Future<bool> isAppleSignInAvailable() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return false;
    }
    return await SignInWithApple.isAvailable();
  }
}
