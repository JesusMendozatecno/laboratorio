import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

/// Botón para alternar entre tema claro y oscuro.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
      onPressed: theme.toggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey<bool>(isDark),
        ),
      ),
    );
  }
}