import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';
import 'institution_picker.dart';

/// CC-NAV-03 — Teoría: materiales y contenido de las materias por institución.
class TeoriaView extends StatelessWidget {
  const TeoriaView({super.key});

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
            title: 'Teoría',
            icon: Icons.menu_book_outlined,
            child: EmptyState(
              icon: Icons.account_balance_outlined,
              title: 'Selecciona una institución',
              description: 'El contenido de teoría se organiza por '
                  'institución y materia.',
            ),
          )
        else ...[
          _MateriasTeoria(institucion: institucion),
          const SizedBox(height: AppDimens.xl),
          _ContenidoTeoria(institucion: institucion),
        ],
      ],
    );
  }
}

class _MateriasTeoria extends StatelessWidget {
  const _MateriasTeoria({required this.institucion});

  final Institucion institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Materias de ${institucion.nombre}',
      icon: Icons.topic_outlined,
      child: StreamBuilder(
        stream: firestore.watch(
          kMateriasCollection,
          filters: [QueryFilter('institucionId', institucion.id)],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final materias = snapshot.data!.docs
              .map((d) => Materia.fromMap({...d.data(), 'id': d.id}))
              .toList();
          if (materias.isEmpty) {
            return const Text(
              'Aún no hay materias registradas. Crea una desde la pestaña '
              'Registro → Materias.',
            );
          }
          return Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: [
              for (final m in materias)
                Chip(
                  avatar: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(m.nombre),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ContenidoTeoria extends StatelessWidget {
  const _ContenidoTeoria({required this.institucion});

  final Institucion institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Contenido de teoría',
      icon: Icons.library_books_outlined,
      padding: EdgeInsets.zero,
      child: StreamBuilder(
        stream: firestore.watch(
          kActividadesCollection,
          filters: [QueryFilter('institucionId', institucion.id)],
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
            ..removeWhere((a) => a.modalidad != Modalidades.teoria)
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Text(
                'Sin contenido de teoría aún. Regístralo desde la pestaña '
                'Registro → Actividades (modalidad Teoría).',
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
                  title: Text(a.tema,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${a.materia} · ${a.fecha}${a.grupo.isNotEmpty ? ' · Grupo ${a.grupo}' : ''}'),
                  leading: const Icon(Icons.menu_book_outlined),
                  isThreeLine: a.contenido.isNotEmpty,
                  trailing: a.contenido.isNotEmpty
                      ? const Icon(Icons.expand_more)
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