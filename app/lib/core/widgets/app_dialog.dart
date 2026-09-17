import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Diálogos y mensajes consistentes en toda la aplicación.
///
/// usa los estilos del tema global (título, acciones, forma) para que todos
/// los diálogos compartan el mismo lenguaje visual.
class AppDialog {
  AppDialog._();

  /// Muestra un diálogo de confirmación.
  ///
  /// Devuelve `true` si el usuario confirma.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                    )
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}