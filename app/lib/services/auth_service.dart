import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

/// Errores de autenticación amigables.
typedef AuthError = String;

/// Abstracción sobre Firebase Auth.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String _secondaryAppName = 'laboratorio-admin';
  FirebaseApp? _secondaryApp;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con correo y contraseña.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Crea una cuenta nueva con correo y contraseña.
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Cierra la sesión.
  Future<void> signOut() => _auth.signOut();

  /// Crea una cuenta sin iniciar sesión en la aplicación principal.
  ///
  /// Se usa una instancia secundaria de Firebase para que la sesión del
  /// administrador que está registrando no se vea afectada.
  Future<UserCredential> createAccountFor(String email, String password) async {
    final app = _secondaryApp ?? await _ensureSecondaryApp();
    final secondaryAuth = FirebaseAuth.instanceFor(app: app);
    final credential = await secondaryAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await secondaryAuth.signOut();
    return credential;
  }

  Future<FirebaseApp> _ensureSecondaryApp() async {
    for (final app in Firebase.apps) {
      if (app.name == _secondaryAppName) {
        return _secondaryApp = app;
      }
    }
    return _secondaryApp = await Firebase.initializeApp(
      name: _secondaryAppName,
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Convierte un código de error de Firebase en un mensaje legible.
  static AuthError messageFrom(Object error) {
    final code = error is FirebaseAuthException ? error.code : '';
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Cédula o contraseña incorrectos.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'La cuenta se encuentra deshabilitada.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifique su red.';
      default:
        return 'Ocurrió un error: ${error is FirebaseAuthException ? error.message : 'intente nuevamente.'}';
    }
  }
}