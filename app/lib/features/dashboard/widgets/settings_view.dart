import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/brand_selector.dart';
import '../../../core/widgets/section_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/security_provider.dart';
import '../../../providers/theme_provider.dart';

/// Pantalla de configuración: cuenta, apariencia e información de la app.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _AccountSection(),
        SizedBox(height: AppDimens.xl),
        _AppearanceSection(),
        SizedBox(height: AppDimens.xl),
        _SecuritySection(),
        SizedBox(height: AppDimens.xl),
        _AboutSection(),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SectionCard(
      title: 'Mi cuenta',
      icon: Icons.account_circle_outlined,
      child: user == null
          ? const Text('No hay una sesión activa.')
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    user.nombre.isNotEmpty
                        ? user.nombre[0].toUpperCase()
                        : '?',
                    style: text.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nombreCompleto,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        UserRoles.labels[user.tipo] ?? user.tipo,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        '${user.cedula} · ${user.correo}',
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Apariencia',
      icon: Icons.palette_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Modo de color',
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimens.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Automático'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {theme.mode},
              onSelectionChanged: (selection) =>
                  theme.setMode(selection.first),
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          Text(
            'Color de marca',
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            'El color de marca tiñe botones, navegación, formularios e '
            'indicadores. Los colores de error, éxito y advertencia no cambian.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppDimens.md),
          const BrandSelector(),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  Future<void> _toggleLock(BuildContext context, bool value) async {
    final security = context.read<SecurityProvider>();
    if (value) {
      final ok = await security.enableLock();
      if (!context.mounted) return;
      if (ok) {
        AppSnackbar.success(context, 'Bloqueo con huella/PIN activado.');
      } else {
        AppSnackbar.error(context, 'No se pudo activar el bloqueo.');
      }
    } else {
      await security.disableLock();
      if (!context.mounted) return;
      AppSnackbar.info(context, 'Bloqueo desactivado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    final supported = security.platformSupported;

    return SectionCard(
      title: 'Seguridad',
      icon: Icons.security_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bloqueo con huella o PIN'),
            subtitle: Text(
              supported
                  ? 'Pide tu huella o PIN al abrir la aplicación y al volver '
                      'del segundo plano.'
                  : 'Disponible en la aplicación móvil (Android/iOS).',
            ),
            value: security.lockEnabled,
            onChanged:
                supported ? (value) => _toggleLock(context, value) : null,
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Acerca de',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.computer_outlined, color: scheme.primary),
              const SizedBox(width: AppDimens.sm),
              Text(
                AppStrings.appName,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          _line(context, 'Laboratorio', AppStrings.labName),
          _line(context, 'Institución', AppStrings.institution),
          _line(context, 'Responsable', AppStrings.labTeacher),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
