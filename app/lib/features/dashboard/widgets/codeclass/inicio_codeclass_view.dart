import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../models/app_user.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';
import '../../presentation/dashboard_layout.dart';
import 'institution_picker.dart';

/// CC-NAV-01 — Inicio: resumen global y por institución (datos reales).
class InicioCodeClassView extends StatelessWidget {
  const InicioCodeClassView({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final institucion = context.watch<InstituccionProvider>().active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeClassBanner(user: user),
        const SizedBox(height: AppDimens.xl),
        InstitutionPicker(),
        const SizedBox(height: AppDimens.xl),
        _StatsGrid(institucion: institucion),
        const SizedBox(height: AppDimens.xl),
        _QuickLinks(),
        const SizedBox(height: AppDimens.xl),
        _ActividadesRecientes(institucion: institucion),
      ],
    );
  }
}

class _CodeClassBanner extends StatelessWidget {
  const _CodeClassBanner({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hour = DateTime.now().hour;
    final saludo = hour < 12
        ? 'Buenos días'
        : (hour < 18 ? 'Buenas tardes' : 'Buenas noches');
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.computer_outlined,
              size: 150,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$saludo 👋',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.xs),
              Text(
                '${user.nombre} ${user.apellido}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.xs),
              Text(
                'Gestiona tus instituciones, estudiantes, equipos y '
                'asistencia. Todo en la nube.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.institucion});

  final Institucion? institucion;

  @override
  Widget build(BuildContext context) {
    final base = institucion == null
        ? null
        : [QueryFilter('institucionId', institucion!.id)];
    final specs = <_StatSpec>[
      _StatSpec(
        kInstitucionesCollection,
        institucion == null ? 'Instituciones' : 'Institución',
        Icons.account_balance_outlined,
        institucion == null
            ? 'Catálogo de instituciones'
            : institucion!.nombre,
        filter: institucion == null ? null : base,
      ),
      _StatSpec(kMateriasCollection, 'Materias', Icons.topic_outlined,
          'Materias del catálogo', filter: base),
      _StatSpec(kEstudiantesCollection, 'Estudiantes', Icons.groups_outlined,
          'Estudiantes registrados', filter: base),
      _StatSpec(kEquiposCollection, 'Equipos', Icons.devices_outlined,
          'Equipos por institución', filter: base),
      _StatSpec(kClasesCollection, 'Clases', Icons.class_outlined,
          'Clases creadas', filter: base),
      _StatSpec(kAsistenciasCollection, 'Asistencias',
          Icons.fact_check_outlined, 'Tomas de asistencia', filter: base),
      _StatSpec(kActividadesCollection, 'Actividades',
          Icons.edit_calendar_outlined, 'Contenido registrado', filter: base),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 3 : (width >= 640 ? 2 : 1);
        final spacing = AppDimens.lg;
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final spec in specs)
              SizedBox(
                width: itemWidth,
                child: _LiveStatCard(spec: spec),
              ),
          ],
        );
      },
    );
  }
}

class _StatSpec {
  const _StatSpec(
    this.collection,
    this.label,
    this.icon,
    this.description, {
    this.filter,
  });

  final String collection;
  final String label;
  final IconData icon;
  final String description;
  final List<QueryFilter>? filter;
}

class _LiveStatCard extends StatelessWidget {
  const _LiveStatCard({required this.spec});

  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore.watch(spec.collection, filters: spec.filter),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StatCard(
              icon: spec.icon,
              value: '—',
              label: spec.label,
              description: spec.description);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return StatCard(
              icon: spec.icon,
              value: '…',
              label: spec.label,
              description: spec.description);
        }
        return StatCard(
          icon: spec.icon,
          value: '${snapshot.data?.docs.length ?? 0}',
          label: spec.label,
          description: spec.description,
        );
      },
    );
  }
}

class _QuickLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.app_registration_outlined, label: 'Registro', tab: 1),
      (icon: Icons.menu_book_outlined, label: 'Teoría', tab: 2),
      (icon: Icons.code_outlined, label: 'Práctica', tab: 3),
    ];
    return SectionCard(
      title: 'Accesos rápidos',
      icon: Icons.bolt_outlined,
      child: Wrap(
        spacing: AppDimens.md,
        runSpacing: AppDimens.md,
        children: [
          for (final it in items)
            OutlinedButton.icon(
              icon: Icon(it.icon),
              label: Text(it.label),
              onPressed: () {
                DashboardIndex.maybeOf(context)?.selectTab(it.tab);
              },
            ),
        ],
      ),
    );
  }
}

class _ActividadesRecientes extends StatelessWidget {
  const _ActividadesRecientes({required this.institucion});

  final Institucion? institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Actividades recientes',
      icon: Icons.history_outlined,
      padding: EdgeInsets.zero,
      child: StreamBuilder(
        stream: firestore.watch(
          kActividadesCollection,
          filters: institucion == null
              ? null
              : [QueryFilter('institucionId', institucion!.id)],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final items = snapshot.data!.docs
              .map((d) => Actividad.fromMap({...d.data(), 'id': d.id}))
              .toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Text(
                'Sin actividades aún. Crea tu primera actividad en la '
                'pestaña Registro.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return Column(
            children: [
              for (final a in items.take(6))
                ListTile(
                  dense: true,
                  leading: Icon(
                    switch (a.modalidad) {
                      Modalidades.teoria => Icons.menu_book_outlined,
                      Modalidades.practica => Icons.code_outlined,
                      _ => Icons.window_outlined,
                    },
                  ),
                  title: Text(a.tema),
                  subtitle: Text(
                    '${a.materia} · ${a.fecha} · ${a.modalidad}'
                    '${a.grupo.isNotEmpty ? ' · Grupo ${a.grupo}' : ''}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}