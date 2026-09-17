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

/// CC-REG-10 — Registro de actividades por clase.
class ActividadesView extends StatelessWidget {
  const ActividadesView({super.key});

  @override
  Widget build(BuildContext context) {
    final institucion = context.watch<InstituccionProvider>().active;
    if (institucion == null) {
      return SectionCard(
        title: 'Actividades',
        icon: Icons.edit_calendar_outlined,
        child: EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Selecciona una institución',
          description: 'Las actividades pertenecen a las clases de una '
              'institución.',
        ),
      );
    }
    return _ActividadesDeInstitucion(institucion: institucion);
  }
}

class _ActividadesDeInstitucion extends StatelessWidget {
  const _ActividadesDeInstitucion({required this.institucion});

  final Institucion institucion;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Clases — ${institucion.nombre}',
      icon: Icons.edit_calendar_outlined,
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
                  'Registre clases antes de crear actividades.',
            );
          }
          return Column(
            children: [
              for (final clase in clases)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(clase.nombreMuestra,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Toca para ver sus actividades'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _ClaseActividadesPage(clase: clase),
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

class _ClaseActividadesPage extends StatefulWidget {
  const _ClaseActividadesPage({required this.clase});

  final Clase clase;

  @override
  State<_ClaseActividadesPage> createState() => _ClaseActividadesPageState();
}

class _ClaseActividadesPageState extends State<_ClaseActividadesPage> {
  void _abrirNueva() {
    showDialog<void>(
      context: context,
      builder: (_) => ActividadDialog(clase: widget.clase),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades — ${widget.clase.nombreMuestra}'),
        actions: [
          IconButton(
            tooltip: 'Nueva actividad',
            icon: const Icon(Icons.add),
            onPressed: _abrirNueva,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNueva,
        icon: const Icon(Icons.add),
        label: const Text('Nueva actividad'),
      ),
      body: StreamBuilder(
        stream: firestore.watch(
          kActividadesCollection,
          filters: [QueryFilter('claseId', widget.clase.id)],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final items = snapshot.data!.docs
              .map((d) => Actividad.fromMap({...d.data(), 'id': d.id}))
              .toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.event_note_outlined,
              title: 'Sin actividades',
              description: 'Pulsa "Nueva actividad" para registrar la primera.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.lg),
            itemCount: items.length,
            itemBuilder: (context, i) => _ActividadTile(
              actividad: items[i],
              onDelete: () => _borrar(items[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _borrar(Actividad a) async {
    final firestore = context.read<FirestoreService>();
    final ok = await AppDialog.confirm(
      context,
      title: 'Eliminar actividad',
      message: '¿Borrar "${a.tema}" del ${a.fecha}?',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (ok != true) return;
    await firestore.delete(kActividadesCollection, a.id);
  }
}

class _ActividadTile extends StatelessWidget {
  const _ActividadTile({required this.actividad, required this.onDelete});

  final Actividad actividad;
  final VoidCallback onDelete;

  (IconData, Color) _tipoIcono(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (actividad.modalidad) {
      case Modalidades.teoria:
        return (Icons.menu_book_outlined, scheme.primary);
      case Modalidades.practica:
        return (Icons.code_outlined, scheme.tertiary);
      default:
        return (Icons.window_outlined, scheme.secondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _tipoIcono(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(actividad.tema,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${actividad.fecha}   ${actividad.modalidad}'
          '${actividad.grupo.isNotEmpty ? ' · Grupo ${actividad.grupo}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (actividad.contenido.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(actividad.contenido),
              ),
            ),
        ],
      ),
    );
  }
}

class ActividadDialog extends StatefulWidget {
  const ActividadDialog({super.key, required this.clase});

  final Clase clase;

  @override
  State<ActividadDialog> createState() => _ActividadDialogState();
}

class _ActividadDialogState extends State<ActividadDialog> {
  final _temaCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  String _fecha = _hoy();
  String _modalidad = Modalidades.teoria;
  String _grupo = '';
  bool _saving = false;

  static String _hoy() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _temaCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
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
    if (_temaCtrl.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Indique el tema de la actividad.');
      return;
    }
    setState(() => _saving = true);
    try {
      final activity = Actividad(
        claseId: widget.clase.id,
        institucionId: widget.clase.institucionId,
        materia: widget.clase.materia,
        modalidad: _modalidad,
        tema: _temaCtrl.text.trim(),
        fecha: _fecha,
        contenido: _contenidoCtrl.text.trim(),
        grupo: _modalidad == Modalidades.laboratorio ? _grupo : '',
        creadoEn: DateTime.now().toIso8601String(),
      );
      await context
          .read<FirestoreService>()
          .add(kActividadesCollection, activity.toMap());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva actividad'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.clase.nombreMuestra,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppDimens.md),
              AppTextField(
                label: 'Tema *',
                hint: 'Ej.: Ciclos while',
                prefixIcon: Icon(Icons.title),
                controller: _temaCtrl,
              ),
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
                      items: const [
                        DropdownMenuItem(
                            value: Modalidades.teoria, child: Text('Teoría')),
                        DropdownMenuItem(
                            value: Modalidades.laboratorio,
                            child: Text('Laboratorio')),
                        DropdownMenuItem(
                            value: Modalidades.practica,
                            child: Text('Práctica')),
                      ],
                      onChanged: (v) => setState(() {
                        _modalidad = v ?? Modalidades.teoria;
                        if (_modalidad != Modalidades.laboratorio) {
                          _grupo = '';
                        }
                      }),
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
                        onChanged: (v) => setState(() => _grupo = v ?? ''),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimens.md),
              AppTextField(
                label: 'Contenido / resumen',
                hint: 'Describe qué se vio, entregables, etc.',
                prefixIcon: Icon(Icons.notes),
                controller: _contenidoCtrl,
                maxLines: 4,
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