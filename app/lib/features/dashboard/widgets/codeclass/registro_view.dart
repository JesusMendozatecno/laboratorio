import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../providers/instituccion_provider.dart';
import 'actividades_view.dart';
import 'asistencia_view.dart';
import 'clases_view.dart';
import 'codeclass_estudiantes_view.dart';
import 'equipos_view.dart';
import 'grupos_view.dart';
import 'institution_picker.dart';
import 'materias_view.dart';

/// CC-NAV-02 — Registro: espacio de trabajo de la institución activa.
///
/// Centraliza la carga de datos por institución en una sola pestaña:
/// Materias, Estudiantes, Equipos, Clases, Grupos, Asistencia y Actividades.
class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  int _subIndex = 0;

  static const _subs = [
    (label: 'Materias', icon: Icons.topic_outlined),
    (label: 'Estudiantes', icon: Icons.groups_outlined),
    (label: 'Equipos', icon: Icons.devices_outlined),
    (label: 'Clases', icon: Icons.class_outlined),
    (label: 'Grupos', icon: Icons.group_work_outlined),
    (label: 'Asistencia', icon: Icons.fact_check_outlined),
    (label: 'Actividades', icon: Icons.edit_calendar_outlined),
  ];

  static const _views = [
    MateriasView(),
    EstudiantesView(),
    EquiposView(),
    ClasesView(),
    GruposView(),
    AsistenciaView(),
    ActividadesView(),
  ];

  @override
  Widget build(BuildContext context) {
    final institucion = context.watch<InstituccionProvider>().active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstitutionPicker(),
        const SizedBox(height: AppDimens.xl),
        if (institucion == null)
          SectionCard(
            title: 'Registro — sin institución',
            icon: Icons.account_balance_outlined,
            child: EmptyState(
              icon: Icons.workspaces_outlined,
              title: 'Selecciona una institución',
              description:
                  'Los registros (materias, estudiantes, equipos, clases, '
                  'grupos, asistencia y actividades) se guardan por '
                  'institución. Usa el selector de arriba o crea una '
                  'institución desde el menú lateral.',
            ),
          )
        else ...[
          SectionCard(
            title: '${_subs[_subIndex].label} — ${institucion.nombre}',
            icon: _subs[_subIndex].icon,
            padding: const EdgeInsets.all(AppDimens.md),
            child: Wrap(
              spacing: AppDimens.xs,
              runSpacing: AppDimens.xs,
              children: [
                for (var i = 0; i < _subs.length; i++)
                  ChoiceChip(
                    label: Text(_subs[i].label),
                    avatar: Icon(_subs[i].icon, size: 18),
                    selected: i == _subIndex,
                    onSelected: (_) => setState(() => _subIndex = i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          KeyedSubtree(
            key: ValueKey<String>(_subs[_subIndex].label),
            child: _views[_subIndex],
          ),
        ],
      ],
    );
  }
}