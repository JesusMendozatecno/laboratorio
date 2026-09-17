import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';

/// Contenedor visual compartido por las pantallas de autenticación.
///
/// En pantallas anchas usa una composición dividida (branding + formulario);
/// en móvil se convierte en una sola columna.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final theme = Theme.of(context);
        final palette = theme.extension<BrandPalette>()!;
        final canPop = Navigator.of(context).canPop();

        final form = Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (canPop) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(height: AppDimens.xs),
                  ],
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimens.xl),
                          child,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return Scaffold(
          body: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _BrandingPanel(palette)),
                    Expanded(flex: 6, child: form),
                  ],
                )
              : Column(
                  children: [
                    _CompactHeader(palette),
                    Expanded(child: form),
                  ],
                ),
        );
      },
    );
  }
}

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel(this.palette);

  final BrandPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    AppStrings.tagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader(this.palette);

  final BrandPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.lg + MediaQuery.paddingOf(context).top,
        AppDimens.lg,
        AppDimens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.start, palette.end],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: const Icon(Icons.science_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            AppStrings.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            AppStrings.tagline,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}