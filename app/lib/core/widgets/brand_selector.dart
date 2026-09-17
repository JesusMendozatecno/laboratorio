import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../theme/app_brand.dart';
import '../theme/app_dimens.dart';

/// Selector de color de marca.
///
/// Permite cambiar el color principal de toda la aplicación. La selección se
/// aplica al instante y se persiste.
class BrandSelector extends StatelessWidget {
  const BrandSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = isDark ? Colors.white : Colors.black87;

    return Wrap(
      spacing: AppDimens.lg,
      runSpacing: AppDimens.sm,
      children: [
        for (final brand in AppBrand.values)
          InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            onTap: () => theme.setBrand(brand),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: brand.seed,
                      shape: BoxShape.circle,
                      border: theme.brand == brand
                          ? Border.all(color: ringColor, width: 3)
                          : null,
                    ),
                    child: theme.brand == brand
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    brand.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: theme.brand == brand
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}