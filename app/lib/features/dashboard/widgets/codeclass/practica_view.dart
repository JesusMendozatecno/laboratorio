import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';
import 'institution_picker.dart';

/// CC-NAV-04 — Práctica: plan de prácticas por institución y catálogo global.
class PracticaView extends StatelessWidget {
  const PracticaView({super.key});

  @override
  Widget build(BuildContext context) {
    final institucion = context.watch<InstituccionProvider>().active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstitutionPicker(),
        const SizedBox(height: AppDimens.xl),
        _PlanPracticas(institucion: institucion),
        const SizedBox(height: AppDimens.xl),
        _CatalogoPracticas(),
      ],
    );
  }
}

class _PlanPracticas extends StatelessWidget {
  const _PlanPracticas({required this.institucion});

  final Institucion? institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: institucion == null
          ? 'Plan de prácticas'
          : 'Plan de prácticas — ${institucion!.nombre}',
      icon: Icons.terminal_outlined,
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
          final items = snapshot.data!.docs
              .map((d) => Actividad.fromMap({...d.data(), 'id': d.id}))
              .toList()
            ..removeWhere((a) => a.modalidad != Modalidades.practica)
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Text(
                institucion == null
                    ? 'Selecciona una institución para ver su plan de '
                        'prácticas.'
                    : 'Sin prácticas planificadas. Créalas desde la pestaña '
                        'Registro → Actividades (modalidad Práctica).',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return Column(
            children: [
              for (final a in items)
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: Text(a.tema,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${a.materia} · ${a.fecha}${a.grupo.isNotEmpty ? ' · Grupo ${a.grupo}' : ''}'),
                  isThreeLine: a.contenido.isNotEmpty,
                  trailing: a.contenido.isNotEmpty
                      ? const Icon(Icons.description_outlined)
                      : null,
                  onTap: a.contenido.isEmpty
                      ? null
                      : () => _verDetail(context, a),
                ),
            ],
          );
        },
      ),
    );
  }

  void _verDetail(BuildContext context, Actividad a) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.tema),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${a.materia} · ${a.fecha} · ${a.modalidad}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppDimens.md),
              Text(a.contenido),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _CatalogoPracticas extends StatelessWidget {
  const _CatalogoPracticas();

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Prácticas de programación (catálogo)',
      icon: Icons.code,
      padding: EdgeInsets.zero,
      child: StreamBuilder(
        stream: firestore.watch(kPracticasCollection),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final items = snapshot.data!.docs;
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.lg),
              child: Text(
                'El catálogo de prácticas está vacío. Créalos desde el menú '
                'lateral → Prácticas.',
              ),
            );
          }
          return Column(
            children: [
              for (final d in items)
                ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(
                    '${d.data()['titulo'] ?? 'Sin título'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${d.data()['materia'] ?? '—'} · ${d.data()['lenguaje'] ?? '—'}'
                    '${d.data()['dificultad'] != null ? ' · ${d.data()['dificultad']}' : ''}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}