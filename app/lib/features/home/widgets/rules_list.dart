import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/page_title.dart';

/// Norma individual con su icono.
class _Rule {
  const _Rule(this.text, this.icon);

  final String text;
  final IconData icon;
}

/// Grupo de normas con un encabezado.
class _RuleSection {
  const _RuleSection(this.title, this.icon, this.rules);

  final String title;
  final IconData icon;
  final List<_Rule> rules;
}

/// Lista de normas del laboratorio agrupadas por categoría y presentadas en
/// una cuadrícula que se adapta al ancho disponible.
class RulesList extends StatelessWidget {
  const RulesList({super.key});

  static const List<_RuleSection> _sections = [
    _RuleSection(
      'Comportamiento y Seguridad',
      Icons.security_outlined,
      [
        _Rule('Ingresar en fila.', Icons.format_line_spacing),
        _Rule('Mantener el lugar ordenado.', Icons.cleaning_services_outlined),
        _Rule('No correr y mantener silencio.', Icons.volume_off_outlined),
        _Rule('Prohibido manipular los equipos con manos sucias.',
            Icons.back_hand_outlined),
        _Rule('No ingresar con alimentos, bebidas o chicles.',
            Icons.no_food_outlined),
        _Rule('Permanecer en el puesto asignado.', Icons.event_seat_outlined),
        _Rule('Levantar la mano para hablar y seguir las indicaciones del profesor.',
            Icons.front_hand_outlined),
        _Rule('Mantener un trato cortés con compañeros y docentes.',
            Icons.handshake_outlined),
      ],
    ),
    _RuleSection(
      'Cuidado de los Equipos',
      Icons.computer_outlined,
      [
        _Rule('No golpear, rayar ni mover los equipos (computadoras, mouse, teclado).',
            Icons.computer_outlined),
        _Rule('No tocar cables eléctricos, desenchufar o mover componentes sin autorización.',
            Icons.electrical_services_outlined),
        _Rule('No instalar, descargar o borrar programas y archivos sin permiso.',
            Icons.app_blocking_outlined),
        _Rule('Apagar los equipos correctamente siguiendo las instrucciones al finalizar.',
            Icons.power_settings_new_outlined),
      ],
    ),
    _RuleSection(
      'Uso de Internet y Recursos',
      Icons.public_outlined,
      [
        _Rule('Prohibido el uso de redes sociales, juegos o videos no relacionados con la clase.',
            Icons.sports_esports_outlined),
        _Rule('No compartir contraseñas y reportar daños o fallas en el equipo.',
            Icons.password_outlined),
        _Rule('Respetar derechos de autor y no plagiar información.',
            Icons.copyright_outlined),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageTitle(
          title: 'Normas del ${AppStrings.labName}',
          description:
              '${AppStrings.institution} · ${AppStrings.labTeacher}',
        ),
        const SizedBox(height: AppDimens.xl),
        for (final section in _sections) ...[
          _SectionHeader(title: section.title, icon: section.icon),
          const SizedBox(height: AppDimens.md),
          _RuleGrid(rules: section.rules),
          const SizedBox(height: AppDimens.xl),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _RuleGrid extends StatelessWidget {
  const _RuleGrid({required this.rules});

  final List<_Rule> rules;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 640;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - AppDimens.lg) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: AppDimens.lg,
          runSpacing: AppDimens.lg,
          children: [
            for (var i = 0; i < rules.length; i++)
              SizedBox(
                width: itemWidth,
                child: _RuleItem(index: i + 1, rule: rules[i]),
              ),
          ],
        );
      },
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.index, required this.rule});

  final int index;
  final _Rule rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimens.radiusXs),
            ),
            child: Icon(
              rule.icon,
              size: 22,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index.toString().padLeft(2, '0'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    rule.text,
                    style: theme.textTheme.bodyMedium,
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