import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mensajes cortos (SnackBars) consistentes.
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, color: AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, color: AppColors.danger);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, color: null);
  }

  static void _show(
    BuildContext context,
    String message, {
    Color? color,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}