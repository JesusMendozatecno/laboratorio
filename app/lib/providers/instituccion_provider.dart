import 'package:flutter/foundation.dart';

import '../models/codeclass_models.dart';

/// Institución activa para el espacio de trabajo actual.
///
/// Al seleccionar una institución (desde el menú lateral o los selectores),
/// todas las pestañas (Inicio, Registro, Teoría, Práctica) filtran sus datos
/// por esa institución.
class InstituccionProvider extends ChangeNotifier {
  Institucion? _active;

  Institucion? get active => _active;
  bool get hasActive => _active != null;
  String? get activeId => _active?.id;

  void select(Institucion? institucion) {
    _active = institucion;
    notifyListeners();
  }

  void clear() => select(null);
}