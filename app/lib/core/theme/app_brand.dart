import 'package:flutter/material.dart';

/// Identidad de marca de la aplicación.
///
/// Cada marca define el color semilla que genera el [ColorScheme] de Material 3
/// y un color profundo que se usa en gradientes y superficies destacadas.
/// Al cambiar la marca, toda la aplicación se adapta automáticamente porque los
/// widgets utilizan `Theme.of(context).colorScheme` en lugar de colores fijos.
enum AppBrand {
  purple('Morado', Color(0xFF6C00FF), Color(0xFF31135E)),
  blue('Azul', Color(0xFF2563EB), Color(0xFF172554)),
  red('Rojo', Color(0xFFDC2626), Color(0xFF450A0A)),
  green('Verde', Color(0xFF16A34A), Color(0xFF052E16)),
  orange('Naranja', Color(0xFFEA580C), Color(0xFF431407)),
  teal('Turquesa', Color(0xFF0891B2), Color(0xFF083344));

  const AppBrand(this.label, this.seed, this.deep);

  /// Nombre visible de la marca.
  final String label;

  /// Color semilla para generar el [ColorScheme].
  final Color seed;

  /// Color profundo usado en gradientes y fondos de marca.
  final Color deep;
}