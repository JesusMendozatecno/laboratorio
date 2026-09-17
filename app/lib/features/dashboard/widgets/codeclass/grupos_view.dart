import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';

/// CC-REG-07 — Registro de grupos por clase.
class GruposView extends StatelessWidget {
  const GruposView({super.key});

  @override
  Widget build(BuildContext context) {
    final institucion = context.watch<InstituccionProvider>().active;
    if (institucion == null) {
      return SectionCard(
        title: 'Grupos',
        icon: Icons.group_work_outlined,
        child: EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Selecciona una institución',
          description: 'Los grupos pertenecen a las clases de una institución.',
        ),
      );
    }
    return _GruposDeInstitucion(institucion: institucion);
  }
}

class _GruposDeInstitucion extends StatelessWidget {
  const _GruposDeInstitucion({required this.institucion});

  final Institucion institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Clases — ${institucion.nombre}',
      icon: Icons.group_work_outlined,
      child: StreamBuilder(
        stream: firestore.watch(
          kClasesCollection,
          filters: [QueryFilter('institucionId', institucion.id)],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final clases = snapshot.data!.docs
              .map((d) => Clase.fromMap({...d.data(), 'id': d.id}))
              .toList();
          if (clases.isEmpty) {
            return EmptyState(
              icon: Icons.class_outlined,
              title: 'Sin clases',
              description: 'Registre clases para asignar grupos.',
            );
          }
          return Column(
            children: [
              for (final clase in clases)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
                  child: ListTile(
                    leading: const Icon(Icons.group_work_outlined),
                    title: Text(clase.nombreMuestra,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Toca para asignar Grupo 1 / Grupo 2'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            _ClaseGruposPage(clase: clase),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ClaseGruposPage extends StatefulWidget {
  const _ClaseGruposPage({required this.clase});

  final Clase clase;

  @override
  State<_ClaseGruposPage> createState() => _ClaseGruposPageState();
}

class _ClaseGruposPageState extends State<_ClaseGruposPage> {
  Map<String, Estudiante> _estudiantes = {};
  bool _changed = false;

  Future<Map<String, Estudiante>> _fetchEstudiantes() async {
    final firestore = context.read<FirestoreService>();
    final docs = await firestore.getAllWithIds(
      kEstudiantesCollection,
      filters: [QueryFilter('institucionId', widget.clase.institucionId)],
    );
    return {for (final d in docs) d['id'] as String: Estudiante.fromMap(d)};
  }

  Future<void> _asignar(String membershipId, String grupo) async {
    await context.read<FirestoreService>().update(
          kClaseEstudiantesCollection,
          membershipId,
          {'grupo': grupo},
        );
    if (!mounted) return;
    setState(() => _changed = true);
    AppSnackbar.info(
        context, grupo.isEmpty ? 'Sin grupo' : 'Grupo $grupo asignado.');
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos — ${widget.clase.nombreMuestra}'),
        actions: [
          if (_changed)
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('Listo'),
            ),
        ],
      ),
      body: FutureBuilder<Map<String, Estudiante>>(
        future: _fetchEstudiantes(),
        builder: (context, fut) {
          if (fut.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          _estudiantes = fut.data ?? {};
          return StreamBuilder(
            stream: firestore.watch(
              kClaseEstudiantesCollection,
              filters: [QueryFilter('claseId', widget.clase.id)],
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final miembros = snapshot.data!.docs
                  .map((d) => ClaseEstudiante.fromMap({...d.data(), 'id': d.id}))
                  .toList()
                ..sort((a, b) {
                  final ea = _estudiantes[a.estudianteId];
                  final eb = _estudiantes[b.estudianteId];
                  if (ea == null || eb == null) return 0;
                  return ea.numeroListaOrden.compareTo(eb.numeroListaOrden);
                });
              if (miembros.isEmpty) {
                return const EmptyState(
                  icon: Icons.group_add_outlined,
                  title: 'Sin estudiantes',
                  description: 'Asigna estudiantes a esta clase primero '
                      '(Registro → Clases → Asignar estudiantes).',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimens.lg),
                itemCount: miembros.length,
                itemBuilder: (context, i) {
                  final m = miembros[i];
                  final est = _estudiantes[m.estudianteId];
                  if (est == null) return const SizedBox.shrink();
                  final grupo = m.grupo;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md,
                        vertical: AppDimens.sm,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text(
                              est.listaFormateada,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(est.nombreCompleto,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                          SegmentedButton<String>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: '1',
                                label: Text('Grupo 1'),
                                icon: Icon(Icons.looks_one_outlined),
                              ),
                              ButtonSegment(
                                value: '2',
                                label: Text('Grupo 2'),
                                icon: Icon(Icons.looks_two_outlined),
                              ),
                            ],
                            selected: grupo.isEmpty
                                ? {}
                                : {grupo},
                            emptySelectionAllowed: true,
                            onSelectionChanged: (sel) {
                              _asignar(m.id, sel.isEmpty ? '' : sel.first);
                            },
                          ),
                          IconButton(
                            tooltip: 'Quitar grupo',
                            icon: const Icon(Icons.undo_outlined),
                            onPressed: () => _asignar(m.id, ''),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}