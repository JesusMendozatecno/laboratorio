import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Tarjeta genérica con superficie y borde del tema.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.lg),
    this.onTap,
    this.borderRadius = AppDimens.radiusMd,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: scheme.outlineVariant, width: 1),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}