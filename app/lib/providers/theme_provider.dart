import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_brand.dart';

/// Maneja la apariencia de la aplicación: modo de color y marca.
///
/// La selección se persiste localmente y afecta a toda la interfaz porque el
/// tema se genera a partir de `brand` y `mode`.
class ThemeProvider extends ChangeNotifier {
  static const _kMode = 'theme_mode';
  static const _kBrand = 'theme_brand';

  ThemeProvider({
    ThemeMode initialMode = ThemeMode.system,
    AppBrand initialBrand = AppBrand.purple,
  })  : _mode = initialMode,
        _brand = initialBrand {
    _restore();
  }

  ThemeMode _mode;
  AppBrand _brand;

  ThemeMode get mode => _mode;
  AppBrand get brand => _brand;

  Future<void> _restore() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final modeIndex = sp.getInt(_kMode);
      final brandIndex = sp.getInt(_kBrand);
      _mode = ThemeMode.values[modeIndex ?? _mode.index];
      _brand = AppBrand.values[brandIndex ?? _brand.index];
      notifyListeners();
    } catch (_) {
      // La preferencia no es crítica: usamos los valores por defecto.
    }
  }

  Brightness get _resolvedBrightness {
    if (_mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
    return _mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  void toggle() {
    final next = _resolvedBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setMode(next);
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    _persist();
  }

  void setBrand(AppBrand brand) {
    if (_brand == brand) return;
    _brand = brand;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt(_kMode, _mode.index);
      await sp.setInt(_kBrand, _brand.index);
    } catch (_) {
      // Si no se puede persistir, el valor sigue activo durante la sesión.
    }
  }
}