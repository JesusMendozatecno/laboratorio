import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Contenedor de sección reutilizable con encabezado opcional.
///
/// Usa colores del tema (superficie, borde, primario) para mantenerse
/// coherente con la marca activa.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.icon,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.lg),
  });

  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasHeader = title != null || icon != null || trailing != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHeader) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSm,
                        ),
                      ),
                      child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: AppDimens.sm),
                  ],
                  Expanded(
                    child: Text(
                      title ?? '',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (trailing != null) ?trailing,
                ],
              ),
              const SizedBox(height: AppDimens.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}