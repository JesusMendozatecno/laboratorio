import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja la seguridad local de la aplicación.
///
/// - Bloqueo con huella/PIN al abrir o volver del segundo plano.
/// - Tiempo de inactividad tras el cual se cierra la sesión.
class SecurityProvider extends ChangeNotifier {
  static const String _kLockEnabled = 'security_lock_enabled';
  static const String _kTimeout = 'security_timeout_minutes';

  /// Minutos de inactividad por defecto antes de cerrar la sesión.
  static const int defaultTimeoutMinutes = 15;

  /// Opciones de tiempo de inactividad (0 = nunca).
  static const List<int> timeoutOptions = [0, 5, 10, 15, 30, 60];

  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _lockEnabled = false;
  bool _locked = false;
  bool _unlocking = false;
  bool _biometricAvailable = false;
  int _timeoutMinutes = defaultTimeoutMinutes;
  bool _ready = false;

  bool get lockEnabled => _lockEnabled;
  bool get isLocked => _lockEnabled && _locked;
  bool get unlocking => _unlocking;
  bool get biometricAvailable => _biometricAvailable;
  bool get ready => _ready;
  int get timeoutMinutes => _timeoutMinutes;

  /// Indica si la plataforma soporta autenticación biométrica/PIN local.
  bool get platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  /// Restaura las preferencias y bloquea la app si estaba activado.
  Future<void> init() async {
    try {
      final sp = await SharedPreferences.getInstance();
      _lockEnabled = sp.getBool(_kLockEnabled) ?? false;
      _timeoutMinutes = sp.getInt(_kTimeout) ?? defaultTimeoutMinutes;
    } catch (_) {
      // Sin preferencias: se usan los valores por defecto.
    }

    if (platformSupported && _lockEnabled) {
      _biometricAvailable = await _checkBiometrics();
      if (!_biometricAvailable) {
        _lockEnabled = false;
      } else {
        _locked = true;
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<bool> _checkBiometrics() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Activa el bloqueo tras verificar que la autenticación funciona.
  Future<bool> enableLock() async {
    if (!platformSupported) return false;
    final ok = await _authenticate(
      'Confirma tu identidad para activar el bloqueo',
    );
    if (!ok) return false;
    _lockEnabled = true;
    _locked = false;
    _biometricAvailable = true;
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> disableLock() async {
    _lockEnabled = false;
    _locked = false;
    notifyListeners();
    await _persist();
  }

  /// Bloquea la app (por ejemplo, al pasar a segundo plano).
  void lock() {
    if (!_lockEnabled || _locked) return;
    _locked = true;
    notifyListeners();
  }

  /// Solicita huella/PIN para desbloquear. Devuelve `true` si lo logra.
  Future<bool> unlock() async {
    if (!isLocked || _unlocking) return !isLocked;
    _unlocking = true;
    notifyListeners();
    final ok = await _authenticate(
      'Desbloquea para acceder al laboratorio',
    );
    _unlocking = false;
    if (ok) _locked = false;
    notifyListeners();
    return ok;
  }

  Future<void> setTimeoutMinutes(int minutes) async {
    if (_timeoutMinutes == minutes) return;
    _timeoutMinutes = minutes;
    notifyListeners();
    await _persist();
  }

  Future<bool> _authenticate(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_kLockEnabled, _lockEnabled);
      await sp.setInt(_kTimeout, _timeoutMinutes);
    } catch (_) {
      // Si no se puede persistir, el valor sigue activo en la sesión.
    }
  }
}
