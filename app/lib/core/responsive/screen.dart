import 'package:flutter/material.dart';

/// Tamaños de pantalla según el ancho disponible.
enum ScreenSize { mobile, tablet, desktop }

/// Breakpoints de la aplicación.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double desktop = 1000;
  static const double wide = 1400;
}

/// Utilidades responsive basadas en el ancho de la pantalla.
extension ScreenSizeX on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < Breakpoints.mobile) return ScreenSize.mobile;
    if (width < Breakpoints.desktop) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;

  bool get isTablet => screenSize == ScreenSize.tablet;

  bool get isDesktop => screenSize == ScreenSize.desktop;
}