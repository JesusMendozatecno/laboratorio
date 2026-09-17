import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/register_screen.dart';
import '../widgets/rules_list.dart';

/// Página de inicio pública con las normas del laboratorio.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: const [ThemeToggleButton(), SizedBox(width: AppDimens.sm)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroBanner(),
                const SizedBox(height: AppDimens.xl),
                _HeroActions(),
                const SizedBox(height: AppDimens.xxxl),
                const RulesList(),
                const SizedBox(height: AppDimens.xxxl),
                Text(
                  '© ${DateTime.now().year} ${AppStrings.appName} — Todos los derechos reservados.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<BrandPalette>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.xxl,
        vertical: AppDimens.xxl,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            bottom: -28,
            child: Icon(
              Icons.science_outlined,
              size: 190,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: const Icon(Icons.science_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      'Gestión de clases, equipos, prácticas y reportes del laboratorio.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<BrandPalette>()!;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: palette.start,
              elevation: 0,
            ),
            onPressed: () => _goTo(context, const LoginScreen()),
            child: const Text('Iniciar Sesión'),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            onPressed: () => _goTo(context, const RegisterScreen()),
            child: const Text('Crear cuenta'),
          ),
        ),
      ],
    );
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}