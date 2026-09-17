import 'package:flutter/material.dart';

import 'app_brand.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

/// Colores derivados de la marca expuestos a través del tema.
///
/// Permite que los widgets accedan a los colores de marca (gradientes, fondos
/// destacados) sin escribir colores fijos dentro de cada widget.
class BrandPalette extends ThemeExtension<BrandPalette> {
  const BrandPalette({required this.start, required this.end});

  /// Color semilla de la marca.
  final Color start;

  /// Color profundo de la marca (gradientes).
  final Color end;

  /// Variante suave del color de marca para fondos tenues.
  Color get soft => start.withValues(alpha: 0.12);

  @override
  BrandPalette copyWith({Color? start, Color? end}) {
    return BrandPalette(start: start ?? this.start, end: end ?? this.end);
  }

  @override
  BrandPalette lerp(ThemeExtension<BrandPalette>? other, double t) {
    if (other is! BrandPalette) return this;
    return BrandPalette(
      start: Color.lerp(start, other.start, t)!,
      end: Color.lerp(end, other.end, t)!,
    );
  }
}

/// Tema claro y oscuro de la aplicación.
///
/// Ambos temas se generan desde el mismo color de marca para mantener un único
/// lenguaje visual adaptado a la luminosidad.
class AppTheme {
  AppTheme._();

  static ThemeData lightFor(AppBrand brand) =>
      _base(Brightness.light, brand);

  static ThemeData darkFor(AppBrand brand) => _base(Brightness.dark, brand);

  static ThemeData _base(Brightness brightness, AppBrand brand) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: brand.seed,
      brightness: brightness,
    );
    final surfaces = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );
    final text = base.textTheme;

    return base.copyWith(
      scaffoldBackgroundColor: surfaces,
      extensions: [
        BrandPalette(start: brand.seed, end: brand.deep),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: surfaces,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: 14),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          textStyle: text.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surfaces,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle:
            text.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        unselectedLabelTextStyle:
            text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaces,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static InputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}