import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Encabezado de página: título y descripción.
///
/// Se usa al inicio del contenido de cada pantalla interna para mantener una
/// jerarquía visual consistente.
class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.lg),
              trailing!,
            ],
          )
        else
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        if (description != null) ...[
          const SizedBox(height: AppDimens.xs),
          Text(
            description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}