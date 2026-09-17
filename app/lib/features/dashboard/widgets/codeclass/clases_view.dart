import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';

const List<String> kAnios = ['', '1ero', '2do', '3ro', '4to', '5to', '6to'];
const List<String> kSecciones = ['', 'A', 'B', 'C', 'D', 'E'];
const List<String> kSemestres = [
  '',
  '1er',
  '2do',
  '3ro',
  '4to',
  '5to',
  '6to',
  '7mo',
  '8vo',
  '9no',
  '10mo',
];

/// CC-REG-06 — Registro de clases por institución.
class ClasesView extends StatefulWidget {
  const ClasesView({super.key});

  @override
  State<ClasesView> createState() => _ClasesViewState();
}

class _ClasesViewState extends State<ClasesView> {
  final _carreraCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  List<Materia> _materias = const [];
  String? _materiaId;
  String _anio = '';
  String _grado = '';
  String _seccion = '';
  String _semestre = '';
  bool _saving = false;

  Institucion? get _institucion => context.watch<InstituccionProvider>().active;

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  Future<void> _loadMaterias() async {
    try {
      final docs = await context
          .read<FirestoreService>()
          .getAllWithIds(kMateriasCollection);
      if (!mounted) return;
      setState(() {
        _materias = docs
            .map(Materia.fromMap)
            .toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
      });
    } catch (_) {
      // El selector mostrará el estado vacío.
    }
  }

  @override
  void dispose() {
    _carreraCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final institucion = _institucion;
    if (institucion == null) return;
    final materia = _materias.where((m) => m.id == _materiaId).firstOrNull;
    if (materia == null) {
      AppSnackbar.error(context, 'Seleccione una materia del catálogo.');
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<FirestoreService>().add(
        kClasesCollection,
        Clase(
          institucionId: institucion.id,
          materiaId: materia.id,
          materia: materia.nombre,
          tipoInst: institucion.tipo,
          anio: _anio,
          grado: _grado,
          seccion: institucion.esColegio ? _seccion : '',
          carrera: institucion.esUniversidad ? _carreraCtrl.text.trim() : '',
          semestre: institucion.esUniversidad ? _semestre : '',
          fecha: _fechaCtrl.text.trim(),
          creadoEn: DateTime.now().toIso8601String(),
        ).toMap(),
      );
      if (!mounted) return;
      setState(() {
        _materiaId = null;
        _anio = '';
        _grado = '';
        _seccion = '';
        _semestre = '';
        _carreraCtrl.clear();
        _fechaCtrl.clear();
      });
      AppSnackbar.success(context, 'Clase registrada.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(Clase clase) async {
    final firestore = context.read<FirestoreService>();
    final ok = await AppDialog.confirm(
      context,
      title: 'Eliminar clase',
      message: '¿Eliminar "${clase.nombreMuestra}"? También se retirarán sus '
          'estudiantes de la clase.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (ok != true) return;
    try {
      await firestore.delete(kClasesCollection, clase.id);
      final miembros = await firestore.getAll(
        kClaseEstudiantesCollection,
        filters: [QueryFilter('claseId', clase.id)],
      );
      for (final m in miembros) {
        await firestore.delete(kClaseEstudiantesCollection, m['id']);
      }
      if (!mounted) return;
      AppSnackbar.success(context, 'Clase eliminada.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final institucion = _institucion;
    if (institucion == null) {
      return SectionCard(
        title: 'Clases',
        icon: Icons.class_outlined,
        child: EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Selecciona una institución',
          description: 'Las clases pertenecen a una institución.',
        ),
      );
    }
    final esquema = institucion.esColegio ? 'Colegio' : 'Universidad';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Registrar clase ($esquema) — ${institucion.nombre}',
          icon: Icons.class_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppDimens.lg,
                runSpacing: AppDimens.lg,
                children: [
                  SizedBox(
                    width: 320,
                    child: DropdownButtonFormField<String>(
                      initialValue: _materiaId,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                      ),
                      items: [
                        for (final m in _materias)
                          DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                      ],
                      hint: const Text('Seleccione la materia'),
                      onChanged: (v) => setState(() => _materiaId = v),
                    ),
                  ),
                  if (institucion.esColegio) ...[
                    SizedBox(
                      width: 130,
                      child: DropdownButtonFormField<String>(
                        initialValue: _anio,
                        decoration: const InputDecoration(
                          labelText: 'Año',
                          prefixIcon: Icon(Icons.numbers_outlined),
                        ),
                        items: [
                          for (final a in kAnios)
                            DropdownMenuItem(value: a, child: Text(a.isEmpty ? '—' : a)),
                        ],
                        onChanged: (v) => setState(() => _anio = v ?? ''),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: DropdownButtonFormField<String>(
                        initialValue: _grado,
                        decoration: const InputDecoration(
                          labelText: 'Grado',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: [
                          for (final a in kAnios)
                            DropdownMenuItem(value: a, child: Text(a.isEmpty ? '—' : a)),
                        ],
                        onChanged: (v) => setState(() => _grado = v ?? ''),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        initialValue: _seccion,
                        decoration: const InputDecoration(
                          labelText: 'Sección',
                          prefixIcon: Icon(Icons.abc_outlined),
                        ),
                        items: [
                          for (final s in kSecciones)
                            DropdownMenuItem(
                                value: s, child: Text(s.isEmpty ? '—' : s)),
                        ],
                        onChanged: (v) => setState(() => _seccion = v ?? ''),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 320,
                      child: AppTextField(
                        label: 'Carrera',
                        hint: 'Ej: Ingeniería en Sistemas',
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                        controller: _carreraCtrl,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        initialValue: _semestre,
                        decoration: const InputDecoration(
                          labelText: 'Semestre',
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        items: [
                          for (final s in kSemestres)
                            DropdownMenuItem(value: s, child: Text(s.isEmpty ? '—' : s)),
                        ],
                        onChanged: (v) => setState(() => _semestre = v ?? ''),
                      ),
                    ),
                  ],
                  SizedBox(
                    width: 180,
                    child: AppTextField(
                      label: 'Fecha (opcional)',
                      hint: 'Ej: 2026-09-20',
                      prefixIcon: const Icon(Icons.event_outlined),
                      controller: _fechaCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              PrimaryButton(
                label: 'Registrar Clase',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        _ClasesLista(
          institucion: institucion,
          onDelete: _delete,
        ),
      ],
    );
  }
}

class _ClasesLista extends StatelessWidget {
  const _ClasesLista({required this.institucion, required this.onDelete});

  final Institucion institucion;
  final ValueChanged<Clase> onDelete;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Clases de ${institucion.nombre}',
      icon: Icons.class_outlined,
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
              description:
                  'Registre la primera clase de ${institucion.nombre}.',
            );
          }
          return Column(
            children: [
              for (final clase in clases)
                _ClaseTile(clase: clase, onDelete: onDelete),
            ],
          );
        },
      ),
    );
  }
}

class _ClaseTile extends StatelessWidget {
  const _ClaseTile({required this.clase, required this.onDelete});

  final Clase clase;
  final ValueChanged<Clase> onDelete;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: StreamBuilder(
        stream: firestore.watch(
          kClaseEstudiantesCollection,
          filters: [QueryFilter('claseId', clase.id)],
        ),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;
          return ListTile(
            leading: const Icon(Icons.class_outlined),
            title: Text(clase.nombreMuestra,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
              '$count estudiantes'
              '${clase.fecha.isNotEmpty ? ' · ${clase.fecha}' : ''}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Asignar estudiantes',
                  icon: const Icon(Icons.group_add_outlined),
                  onPressed: () async {
                    final set = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClaseEstudiantesPage(clase: clase),
                      ),
                    );
                    if (set == true && context.mounted) {
                      AppSnackbar.success(
                          context, 'Estudiantes actualizados.');
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () => onDelete(clase),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Página de asignación de estudiantes a una clase (búsqueda, agregar,
/// retirar).
class ClaseEstudiantesPage extends StatefulWidget {
  const ClaseEstudiantesPage({super.key, required this.clase});

  final Clase clase;

  @override
  State<ClaseEstudiantesPage> createState() => _ClaseEstudiantesPageState();
}

class _ClaseEstudiantesPageState extends State<ClaseEstudiantesPage> {
  String _query = '';
  Map<String, Map<String, dynamic>> _miembros = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final firestore = context.read<FirestoreService>();
    final docs = await firestore.getAllWithIds(
      kClaseEstudiantesCollection,
      filters: [QueryFilter('claseId', widget.clase.id)],
    );
    if (!mounted) return;
    setState(() {
      _miembros = {for (final d in docs) d['estudianteId'] as String: d};
      _loading = false;
    });
  }

  Future<void> _toggle(Estudiante estudiante, bool enClase) async {
    final firestore = context.read<FirestoreService>();
    try {
      if (enClase) {
        await firestore.add(kClaseEstudiantesCollection, {
          'claseId': widget.clase.id,
          'estudianteId': estudiante.id,
          'grupo': '',
        });
      } else {
        final m = _miembros[estudiante.id];
        if (m != null) {
          await firestore.delete(kClaseEstudiantesCollection, m['id']);
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Estudiantes — ${widget.clase.nombreMuestra}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar estudiante…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore.watch(
                kEstudiantesCollection,
                filters: [
                  QueryFilter('institucionId', widget.clase.institucionId),
                ],
              ),
              builder: (context, snapshot) {
                if (_loading || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final estudiantes = (snapshot.data?.docs ?? [])
                    .map((d) => Estudiante.fromMap({...d.data(), 'id': d.id}))
                    .toList()
                  ..sort((a, b) => a.numeroListaOrden.compareTo(b.numeroListaOrden));
                final filtrados = estudiantes
                    .where((e) =>
                        _query.isEmpty ||
                        e.nombreCompleto
                            .toLowerCase()
                            .contains(_query.toLowerCase()) ||
                        e.cedula.contains(_query))
                    .toList();
                if (filtrados.isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'Sin resultados',
                    description:
                        'Registra estudiantes en la sección de estudiantes '
                        'para poder asignarlos.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  itemCount: filtrados.length,
                  itemBuilder: (context, i) {
                    final e = filtrados[i];
                    final esMiembro = _miembros.containsKey(e.id);
                    final grupo = esMiembro
                        ? (_miembros[e.id]?['grupo'] as String? ?? '')
                        : '';
                    return SwitchListTile(
                      title: Text('${e.listaFormateada} — ${e.nombreCompleto}'),
                      subtitle: Text('Cédula: ${e.cedula}'
                          '${grupo.isNotEmpty ? " · ${Grupos.label(grupo)}" : ''}'),
                      value: esMiembro,
                      onChanged: (v) => _toggle(e, v),
                      secondary: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Text(
                          e.listaFormateada,
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}