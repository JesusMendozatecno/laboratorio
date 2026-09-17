import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Tarjeta de estadística con icono, valor y etiqueta.
///
/// El color del acento se define con `color` y solo cuando aporta significado;
/// por defecto se usa el color primario de la marca.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.description,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? description;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final accent = color ?? scheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Icon(icon, size: 24, color: accent),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            Text(
              value,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              label,
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              const SizedBox(height: AppDimens.xs),
              Text(
                description!,
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}