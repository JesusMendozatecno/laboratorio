import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../models/app_user.dart';
import '../../../services/firestore_service.dart';

/// Vista de bienvenida común a todos los roles, con estadísticas reales.
class InicioView extends StatelessWidget {
  const InicioView({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WelcomeBanner(user: user),
        const SizedBox(height: AppDimens.xl),
        const _StatsGrid(),
        const SizedBox(height: AppDimens.xl),
        const SectionCard(
          title: '¿Qué puedes hacer aquí?',
          icon: Icons.lightbulb_outline,
          child: Text(
            'Usa el menú lateral para registrar clases, equipos, profesores, '
            'institutos o reportes. La información se guarda en la nube '
            '(Firebase) y se sincroniza en todos tus dispositivos.',
          ),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<BrandPalette>()!;
    final rol = UserRoles.labels[user.tipo] ?? user.tipo;

    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
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
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.science_outlined,
              size: 150,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 34),
              ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${user.nombre}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      '$rol • Cédula: ${user.cedula}',
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

/// Estadísticas en vivo por colección de Firestore.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  static final List<_StatSpec> _stats = [
    _StatSpec(kClasesCollection, 'Clases', Icons.class_outlined,
        'Clases registradas'),
    _StatSpec(kProfesoresCollection, 'Profesores', Icons.school_outlined,
        'Profesores registrados'),
    _StatSpec(kEquiposCollection, 'Equipos', Icons.devices_outlined,
        'Equipos del laboratorio'),
    _StatSpec(kInstitutosCollection, 'Institutos', Icons.account_balance_outlined,
        'Institutos asociados'),
    _StatSpec(kReportesCollection, 'Reportes', Icons.analytics_outlined,
        'Reportes enviados'),
    _StatSpec(
      kUsuariosCollection,
      'Inscritos',
      Icons.people_outline,
      'Estudiantes inscritos',
      filter: const QueryFilter('tipo', UserRoles.estudiante),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            for (final spec in _stats)
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
  final QueryFilter? filter;
}

class _LiveStatCard extends StatelessWidget {
  const _LiveStatCard({required this.spec});

  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore.watch(
        spec.collection,
        filters: spec.filter == null ? null : [spec.filter!],
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StatCard(
            icon: spec.icon,
            value: '—',
            label: spec.label,
            description: spec.description,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return StatCard(
            icon: spec.icon,
            value: '…',
            label: spec.label,
            description: spec.description,
          );
        }
        final count = snapshot.data?.docs.length ?? 0;
        return StatCard(
          icon: spec.icon,
          value: '$count',
          label: spec.label,
          description: spec.description,
        );
      },
    );
  }
}