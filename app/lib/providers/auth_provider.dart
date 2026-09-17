import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Estados posibles del inicio de la aplicación.
enum AuthStatus { unknown, unauthenticated, authenticated }

/// Maneja la sesión del usuario (Firebase Auth + perfil en Firestore).
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestore = firestoreService {
    _init();
  }

  final AuthService _authService;
  final FirestoreService _firestore;

  StreamSubscription<User?>? _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _isBusy = false;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _isBusy;
  String? get error => _error;

  void _init() {
    _subscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _user = await _firestore.getUserByUid(user.uid);
      } else {
        _user = null;
      }
      _status = _user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  /// Inicia sesión aceptando correo o cédula en el mismo campo.
  Future<bool> login(String identifier, String password) async {
    _setBusy();
    try {
      var email = identifier.trim();
      // Si el usuario escribió una cédula (solo números), buscar el correo.
      if (!email.contains('@')) {
        final found = await _firestore.getUserByCedula(email);
        if (found == null) {
          throw Exception('Cédula no registrada');
        }
        email = found.correo;
      }
      await _authService.signInWithEmail(email, password);
      return true;
    } catch (e) {
      _error = AuthService.messageFrom(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Registra un usuario nuevo (Auth + Firestore).
  Future<bool> register({
    required String nombre,
    required String apellido,
    required String cedula,
    required String correo,
    required String password,
    required String tipo,
  }) async {
    _setBusy();
    try {
      final cred = await _authService.signUp(correo, password);
      final user = AppUser(
        uid: cred.user!.uid,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        cedula: cedula.trim(),
        correo: correo.trim(),
        tipo: tipo,
      );
      await _firestore.saveUser(user);
      _user = user;
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = AuthService.messageFrom(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isBusy = true;
    notifyListeners();
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _isBusy = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setBusy() {
    _isBusy = true;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}