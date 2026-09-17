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

/// CC-REG-05 — Registro de estudiantes por institución.
class EstudiantesView extends StatefulWidget {
  const EstudiantesView({super.key});

  @override
  State<EstudiantesView> createState() => _EstudiantesViewState();
}

class _EstudiantesViewState extends State<EstudiantesView> {
  final _nCtrl = TextEditingController();
  final _aCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _eCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _lCtrl = TextEditingController();
  bool _saving = false;
  String _query = '';

  Institucion? get _institucion => context.watch<InstituccionProvider>().active;

  @override
  void dispose() {
    _nCtrl.dispose();
    _aCtrl.dispose();
    _cCtrl.dispose();
    _eCtrl.dispose();
    _correoCtrl.dispose();
    _telCtrl.dispose();
    _lCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final institucion = _institucion;
    if (institucion == null) return;
    final nombre = _nCtrl.text.trim();
    final apellido = _aCtrl.text.trim();
    if (nombre.isEmpty || apellido.isEmpty) {
      AppSnackbar.error(context, 'Nombre y apellido son obligatorios.');
      return;
    }
    setState(() => _saving = true);
    try {
      final firestore = context.read<FirestoreService>();
      final existentes = await firestore.getAll(
        kEstudiantesCollection,
        filters: [QueryFilter('institucionId', institucion.id)],
      );
      final cedula = _cCtrl.text.trim();
      if (cedula.isNotEmpty &&
          existentes.any((e) => e['cedula'] == cedula)) {
        if (!mounted) return;
        AppSnackbar.error(context, 'Ya existe un estudiante con esa cédula.');
        setState(() => _saving = false);
        return;
      }
      await firestore.add(
        kEstudiantesCollection,
        Estudiante(
          institucionId: institucion.id,
          nombre: nombre,
          apellido: apellido,
          cedula: cedula,
          edad: _eCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          telefono: _telCtrl.text.trim(),
          numeroLista: _lCtrl.text.trim(),
          creadoEn: DateTime.now().toIso8601String(),
        ).toMap(),
      );
      if (!mounted) return;
      for (final c in [
        _nCtrl,
        _aCtrl,
        _cCtrl,
        _eCtrl,
        _correoCtrl,
        _telCtrl,
        _lCtrl,
      ]) {
        c.clear();
      }
      AppSnackbar.success(context, 'Estudiante registrado.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(Estudiante estudiante) async {
    final firestore = context.read<FirestoreService>();
    final ok = await AppDialog.confirm(
      context,
      title: 'Quitar estudiante',
      message: '¿Quitar a "${estudiante.nombreCompleto}" de '
          '"${_institucion?.nombre}"?',
      confirmLabel: 'Quitar',
      destructive: true,
    );
    if (ok != true) return;
    try {
      await firestore.delete(kEstudiantesCollection, estudiante.id);
      final miembros = await firestore.getAll(
        kClaseEstudiantesCollection,
        filters: [QueryFilter('estudianteId', estudiante.id)],
      );
      for (final m in miembros) {
        await firestore.delete(kClaseEstudiantesCollection, m['id']);
      }
      if (!mounted) return;
      AppSnackbar.success(context, 'Estudiante eliminado.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final institucion = _institucion;
    if (institucion == null) {
      return _SinInstitucion();
    }
    final esColegio = institucion.esColegio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Registrar estudiante — ${institucion.nombre}',
          icon: Icons.person_add_alt_outlined,
          trailing: PrimaryButton(
            label: 'Registrar',
            icon: Icons.person_add_outlined,
            isLoading: _saving,
            onPressed: _save,
          ),
          child: Wrap(
            spacing: AppDimens.lg,
            runSpacing: AppDimens.lg,
            children: [
              SizedBox(
                width: 140,
                child: AppTextField(
                  label: esColegio
                      ? 'Nº de lista'
                      : 'Nº de lista (opc.)',
                  hint: 'Ej: 1',
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  keyboardType: TextInputType.number,
                  controller: _lCtrl,
                ),
              ),
              SizedBox(
                width: 220,
                child: AppTextField(
                  label: 'Nombre',
                  prefixIcon: const Icon(Icons.person_outline),
                  controller: _nCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
              ),
              SizedBox(
                width: 220,
                child: AppTextField(
                  label: 'Apellido',
                  prefixIcon: const Icon(Icons.person_outline),
                  controller: _aCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
              ),
              SizedBox(
                width: 180,
                child: AppTextField(
                  label: 'Cédula',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  keyboardType: TextInputType.number,
                  controller: _cCtrl,
                ),
              ),
              SizedBox(
                width: 120,
                child: AppTextField(
                  label: 'Edad',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  keyboardType: TextInputType.number,
                  controller: _eCtrl,
                ),
              ),
              SizedBox(
                width: 280,
                child: AppTextField(
                  label: 'Correo (opcional)',
                  prefixIcon: const Icon(Icons.mail_outline),
                  keyboardType: TextInputType.emailAddress,
                  controller: _correoCtrl,
                ),
              ),
              SizedBox(
                width: 240,
                child: AppTextField(
                  label: 'Teléfono (opcional)',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  controller: _telCtrl,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        _EstudiantesLista(
          institucion: institucion,
          query: _query,
          onQuery: (q) => setState(() => _query = q),
          onDelete: _delete,
        ),
      ],
    );
  }
}

class _SinInstitucion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Estudiantes',
      icon: Icons.groups_outlined,
      child: EmptyState(
        icon: Icons.account_balance_outlined,
        title: 'Selecciona una institución',
        description: 'Usa el selector de institución o el menú lateral para '
            'trabajar con los estudiantes de una institución.',
      ),
    );
  }
}

class _EstudiantesLista extends StatelessWidget {
  const _EstudiantesLista({
    required this.institucion,
    required this.query,
    required this.onQuery,
    required this.onDelete,
  });

  final Institucion institucion;
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<Estudiante> onDelete;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Estudiantes de ${institucion.nombre}',
      icon: Icons.groups_outlined,
      child: StreamBuilder(
        stream: firestore.watch(
          kEstudiantesCollection,
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
          final todos = snapshot.data!.docs
              .map((d) => Estudiante.fromMap({...d.data(), 'id': d.id}))
              .toList();
          todos.sort((a, b) {
            final ln = a.numeroListaOrden.compareTo(b.numeroListaOrden);
            return ln != 0 ? ln : a.nombreCompleto.compareTo(b.nombreCompleto);
          });
          final estudiantes = todos
              .where((e) =>
                  query.isEmpty ||
                  e.nombreCompleto.toLowerCase().contains(query.toLowerCase()) ||
                  e.cedula.contains(query))
              .toList();
          if (estudiantes.isEmpty) {
            return EmptyState(
              icon: Icons.groups_outlined,
              title: 'Sin estudiantes',
              description: query.isEmpty
                  ? 'Registre el primer estudiante de esta institución.'
                  : 'No hay coincidencias con la búsqueda.',
            );
          }
          return Column(
            children: [
              TextField(
                onChanged: onQuery,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o cédula…',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              for (final estudiante in estudiantes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 44,
                    child: Text(
                      institucion.esColegio ? estudiante.listaFormateada : '•',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  title: Text(
                    institucion.esColegio
                        ? estudiante.nombreCompleto
                        : '${estudiante.listaFormateada} — '
                            '${estudiante.nombreCompleto}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (estudiante.cedula.isNotEmpty)
                        Text('Cédula: ${estudiante.cedula}'),
                      if (estudiante.edad.isNotEmpty)
                        Text('Edad: ${estudiante.edad}'),
                    ],
                  ),
                  isThreeLine: estudiante.edad.isNotEmpty,
                  trailing: IconButton(
                    tooltip: 'Quitar',
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => onDelete(estudiante),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}