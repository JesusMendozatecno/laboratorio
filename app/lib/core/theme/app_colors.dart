import 'package:flutter/material.dart';

/// Colores de aplicación que no dependen de la marca.
///
/// Los widgets deben leer el resto de colores (primario, superficie, bordes…)
/// desde `Theme.of(context).colorScheme` para que el cambio de marca se
/// propague automáticamente. Aquí solo se centralizan colores neutros y los
/// semánticos (los que tienen significado funcional y no cambian con la marca).
class AppColors {
  AppColors._();

  /// Superficies en modo claro.
  static const Color lightSurface = Color(0xFFF4F6FB);

  /// Superficies en modo oscuro.
  static const Color darkSurface = Color(0xFF111318);

  /// Superficie elevada en modo oscuro.
  static const Color darkElevated = Color(0xFF1B1F27);

  /// Color semántico de error (no cambia con la marca).
  static const Color danger = Color(0xFFE53935);

  /// Color semántico de éxito (no cambia con la marca).
  static const Color success = Color(0xFF43A047);

  /// Color semántico de advertencia (no cambia con la marca).
  static const Color warning = Color(0xFFFB8C00);
}