import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';

/// CC-REG-08 — Registro de asistencia por clase.
class AsistenciaView extends StatelessWidget {
  const AsistenciaView({super.key});

  @override
  Widget build(BuildContext context) {
    final institucion = context.watch<InstituccionProvider>().active;
    if (institucion == null) {
      return SectionCard(
        title: 'Asistencia',
        icon: Icons.fact_check_outlined,
        child: EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Selecciona una institución',
          description: 'La asistencia pertenece a las clases de una '
              'institución.',
        ),
      );
    }
    return _AsistenciaDeInstitucion(institucion: institucion);
  }
}

class _AsistenciaDeInstitucion extends StatelessWidget {
  const _AsistenciaDeInstitucion({required this.institucion});

  final Institucion institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Clases — ${institucion.nombre}',
      icon: Icons.fact_check_outlined,
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
                  'Registre clases para poder tomar asistencia.',
            );
          }
          return Column(
            children: [
              for (final clase in clases)
                _ClaseAsistenciaTile(clase: clase),
            ],
          );
        },
      ),
    );
  }
}

class _ClaseAsistenciaTile extends StatelessWidget {
  const _ClaseAsistenciaTile({required this.clase});

  final Clase clase;

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
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(clase.nombreMuestra,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('$count estudiantes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _ClaseAsistenciaPage(clase: clase)),
            ),
          );
        },
      ),
    );
  }
}

/// Historial + registro de asistencia de una clase.
class _ClaseAsistenciaPage extends StatefulWidget {
  const _ClaseAsistenciaPage({required this.clase});

  final Clase clase;

  @override
  State<_ClaseAsistenciaPage> createState() => _ClaseAsistenciaPageState();
}

class _ClaseAsistenciaPageState extends State<_ClaseAsistenciaPage> {
  Map<String, Estudiante> _estudiantes = {};
  List<Map<String, dynamic>> _miembros = [];

  Future<void> _cargarDatos() async {
    final firestore = context.read<FirestoreService>();
    final estudiantes = await firestore.getAllWithIds(
      kEstudiantesCollection,
      filters: [QueryFilter('institucionId', widget.clase.institucionId)],
    );
    final miembros = await firestore.getAllWithIds(
      kClaseEstudiantesCollection,
      filters: [QueryFilter('claseId', widget.clase.id)],
    );
    if (!mounted) return;
    setState(() {
      _estudiantes = {
        for (final d in estudiantes) d['id'] as String: Estudiante.fromMap(d),
      };
      _miembros = miembros;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _abrirRegistro() {
    final estudiantesClase = _estudiantesDeLaClase();
    showDialog<void>(
      context: context,
      builder: (_) => AsistenciaDialog(
        clase: widget.clase,
        estudiantes: estudiantesClase,
        miembros: _miembros,
      ),
    );
  }

  List<Estudiante> _estudiantesDeLaClase() {
    final ids = _miembros.map((m) => m['estudianteId'] as String).toSet();
    final lista = _estudiantes.values.where((e) => ids.contains(e.id)).toList()
      ..sort((a, b) => a.numeroListaOrden.compareTo(b.numeroListaOrden));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final estudiantesClase = _estudiantesDeLaClase();
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia — ${widget.clase.nombreMuestra}'),
        actions: [
          IconButton(
            tooltip: 'Registrar asistencia',
            icon: const Icon(Icons.add),
            onPressed: () => _abrirRegistro(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirRegistro(),
        icon: const Icon(Icons.fact_check_outlined),
        label: const Text('Registrar asistencia'),
      ),
      body: Column(
        children: [
          if (estudiantesClase.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppDimens.xl),
              child: EmptyState(
                icon: Icons.group_add_outlined,
                title: 'Clase sin estudiantes',
                description: 'Asigna estudiantes a esta clase (Registro → '
                    'Clases → Asignar estudiantes) antes de tomar asistencia.',
              ),
            )
          else
            Expanded(
              child: StreamBuilder(
                stream: firestore.watch(
                  kAsistenciasCollection,
                  filters: [QueryFilter('claseId', widget.clase.id)],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final asistencias = snapshot.data!.docs
                      .map((d) => Asistencia.fromMap({...d.data(), 'id': d.id}))
                      .toList()
                    ..sort((a, b) => a.fecha.compareTo(b.fecha));
                  if (asistencias.isEmpty) {
                    return const EmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: 'Sin registros',
                      description: 'Pulsa "Registrar asistencia" para la '
                          'primera fecha.',
                    );
                  }
                  return _AttendanceTable(
                    estudiantes: estudiantesClase,
                    asistencias: asistencias,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Tabla de asistencia con columnas dinámicas por fecha (✓ / X / —).
class _AttendanceTable extends StatelessWidget {
  const _AttendanceTable({
    required this.estudiantes,
    required this.asistencias,
  });

  final List<Estudiante> estudiantes;
  final List<Asistencia> asistencias;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppDimens.lg),
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerHighest),
        columns: [
          const DataColumn(label: Text('N°',
              style: TextStyle(fontWeight: FontWeight.w700))),
          const DataColumn(label: Text('Nombre',
              style: TextStyle(fontWeight: FontWeight.w700))),
          const DataColumn(label: Text('Apellido',
              style: TextStyle(fontWeight: FontWeight.w700))),
          for (final a in asistencias)
            DataColumn(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(a.fecha,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (a.grupo.isNotEmpty || a.modalidad.isNotEmpty)
                    Text(
                      '${a.grupo.isNotEmpty ? 'G${a.grupo} ' : ''}${a.modalidad}',
                      style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
        ],
        rows: [
          for (final e in estudiantes)
            DataRow(
              cells: [
                DataCell(Text(e.listaFormateada)),
                DataCell(Text(e.nombre)),
                DataCell(Text(e.apellido)),
                for (final a in asistencias)
                  DataCell(
                    a.estudiantes[e.id] == null
                        ? const Text('—')
                        : Icon(
                            a.estudiantes[e.id]!
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 20,
                            color: a.estudiantes[e.id]!
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// CC-REG-09 — Modal para registrar asistencia.
class AsistenciaDialog extends StatefulWidget {
  const AsistenciaDialog({
    super.key,
    required this.clase,
    required this.estudiantes,
    required this.miembros,
  });

  final Clase clase;
  final List<Estudiante> estudiantes;
  final List<Map<String, dynamic>> miembros;

  @override
  State<AsistenciaDialog> createState() => _AsistenciaDialogState();
}

class _AsistenciaDialogState extends State<AsistenciaDialog> {
  String _fecha = _hoy();
  String _modalidad = Modalidades.teoria;
  String _grupo = '';
  final Map<String, bool> _estados = {};
  bool _saving = false;

  static String _hoy() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    for (final e in widget.estudiantes) {
      _estados[e.id] = true;
    }
    _aplicarFiltroGrupo();
  }

  List<Estudiante> get _visibles {
    if (_modalidad == Modalidades.laboratorio && _grupo.isNotEmpty) {
      final grupoIds = widget.miembros
          .where((m) => m['grupo'] == _grupo)
          .map((m) => m['estudianteId'] as String)
          .toSet();
      return widget.estudiantes.where((e) => grupoIds.contains(e.id)).toList();
    }
    return widget.estudiantes;
  }

  void _aplicarFiltroGrupo() {
    final visibles = _visibles.map((e) => e.id).toSet();
    final copia = Map<String, bool>.from(_estados);
    for (final v in visibles) {
      copia[v] ??= true;
    }
    _estados..clear()..addAll(copia);
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fecha) ?? hoy,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _fecha = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _guardar() async {
    final visibles = _visibles.map((e) => e.id).toSet();
    if (visibles.isEmpty) {
      AppSnackbar.error(context,
          _modalidad == Modalidades.laboratorio
              ? 'Ese grupo no tiene estudiantes asignados.'
              : 'La clase no tiene estudiantes.');
      return;
    }
    setState(() => _saving = true);
    try {
      final firestore = context.read<FirestoreService>();
      final deLaClase = await firestore.getAllWithIds(
        kAsistenciasCollection,
        filters: [QueryFilter('claseId', widget.clase.id)],
      );
      final existentes = deLaClase.where((d) {
        final data = d;
        return data['fecha'] == _fecha &&
            data['modalidad'] == _modalidad &&
            (data['grupo'] ?? '') == _grupo;
      }).toList();
      final estudiantesMap = {
        for (final e in widget.estudiantes) e.id: (_estados[e.id] ?? false),
      };
      final data = {
        'claseId': widget.clase.id,
        'institucionId': widget.clase.institucionId,
        'fecha': _fecha,
        'modalidad': _modalidad,
        'grupo': _grupo,
        'estudiantes': estudiantesMap,
      };
      if (existentes.isNotEmpty) {
        await firestore.update(
            kAsistenciasCollection, existentes.first['id'], data);
      } else {
        await firestore.add(kAsistenciasCollection,
            {...data, 'creadoEn': DateTime.now().toIso8601String()});
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
      setState(() => _saving = false);
    }
  }

  void _marcarTodos(bool presente) {
    setState(() {
      for (final v in _visibles) {
        _estados[v.id] = presente;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visibles = _visibles;
    return AlertDialog(
      title: const Text('Registrar asistencia'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.clase.nombreMuestra,
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppDimens.md),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _elegirFecha,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        child: Text(_fecha),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _modalidad,
                      decoration: const InputDecoration(
                        labelText: 'Modalidad',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final m in Modalidades.teoriaLaboratorio)
                          DropdownMenuItem(value: m, child: Text(m)),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _modalidad = v;
                          if (_modalidad != Modalidades.laboratorio) {
                            _grupo = '';
                          }
                        });
                        _aplicarFiltroGrupo();
                      },
                    ),
                  ),
                  if (_modalidad == Modalidades.laboratorio) ...[
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _grupo,
                        decoration: const InputDecoration(
                          labelText: 'Grupo',
                          prefixIcon: Icon(Icons.group_work_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('—')),
                          DropdownMenuItem(value: '1', child: Text('Grupo 1')),
                          DropdownMenuItem(value: '2', child: Text('Grupo 2')),
                        ],
                        onChanged: (v) {
                          setState(() => _grupo = v ?? '');
                          _aplicarFiltroGrupo();
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Row(
                children: [
                  Text(
                    '${visibles.length} estudiantes',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: () => _marcarTodos(true),
                      child: const Text('Todos presentes')),
                  TextButton(
                      onPressed: () => _marcarTodos(false),
                      child: const Text('Todos ausentes')),
                ],
              ),
              const Divider(),
              if (visibles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppDimens.md),
                  child: EmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'Sin estudiantes',
                    description:
                        _seleccionaGrupoText,
                  ),
                )
              else
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 240),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final e in visibles)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: SizedBox(
                            width: 36,
                            child: Text(
                              e.listaFormateada,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          title: Text(e.nombreCompleto),
                          trailing: SegmentedButton<bool>(
                            showSelectedIcon: false,
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: true,
                                label: Text('Asistente'),
                                icon: Icon(Icons.check),
                              ),
                              ButtonSegment(
                                value: false,
                                label: Text('Inasistente'),
                                icon: Icon(Icons.close),
                              ),
                            ],
                            selected: {_estados[e.id] ?? true},
                            onSelectionChanged: (sel) => setState(() {
                              _estados[e.id] = sel.first;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        PrimaryButton(
          label: 'Guardar',
          icon: Icons.save_outlined,
          isLoading: _saving,
          onPressed: _guardar,
        ),
      ],
    );
  }
}

const String _seleccionaGrupoText =
    'Seleccione o asigne estudiantes a este grupo.';