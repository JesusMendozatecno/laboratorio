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

/// CC-REG-02 — Registro de instituciones.
class InstitucionesView extends StatefulWidget {
  const InstitucionesView({super.key});

  @override
  State<InstitucionesView> createState() => _InstitucionesViewState();
}

class _InstitucionesViewState extends State<InstitucionesView> {
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  String _tipo = InstitucionTypes.colegio;
  bool _pequenosIngenieros = false;
  bool _saving = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      AppSnackbar.error(context, 'Escriba el nombre de la institución.');
      return;
    }
    setState(() => _saving = true);
    try {
      final firestore = context.read<FirestoreService>();
      final existentes = await firestore.getAll(kInstitucionesCollection);
      final duplicada = existentes.any((i) =>
          ((i['nombre'] as String? ?? '').toLowerCase()) ==
          nombre.toLowerCase());
      if (duplicada) {
        if (!mounted) return;
        AppSnackbar.error(context, 'Esa institución ya está registrada.');
        setState(() => _saving = false);
        return;
      }
      await firestore.add(kInstitucionesCollection, {
        'nombre': nombre,
        'tipo': _tipo,
        'pequenosIngenieros': _pequenosIngenieros,
        'direccion': _direccionCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'creadoEn': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      _nombreCtrl.clear();
      _direccionCtrl.clear();
      _telefonoCtrl.clear();
      setState(() {
        _tipo = InstitucionTypes.colegio;
        _pequenosIngenieros = false;
      });
      AppSnackbar.success(context, 'Institución registrada.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(Institucion institucion) async {
    final firestore = context.read<FirestoreService>();
    final ok = await AppDialog.confirm(
      context,
      title: 'Eliminar institución',
      message: '¿Eliminar "${institucion.nombre}"? Sus estudiantes, clases, '
          'equipos y asistencias asociados se conservarán en la base, pero '
          'dejarán de mostrarse.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (ok != true) return;
    try {
      await firestore
          .delete(kInstitucionesCollection, institucion.id);
      if (!mounted) return;
      AppSnackbar.success(context, 'Institución eliminada.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
    }
  }

  void _seleccionar(Institucion institucion) {
    context.read<InstituccionProvider>().select(institucion);
    AppSnackbar.info(context,
        'Institución activa: ${institucion.nombre}. Los datos ahora '
        'pertenecen solo a esta institución.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Registrar institución',
          icon: Icons.account_balance_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Nombre de la institución',
                hint: 'Ej: Los Ángeles, UNEFA…',
                prefixIcon: const Icon(Icons.account_balance_outlined),
                controller: _nombreCtrl,
              ),
              const SizedBox(height: AppDimens.lg),
              Wrap(
                spacing: AppDimens.lg,
                runSpacing: AppDimens.lg,
                children: [
                  SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de institución',
                        prefixIcon: Icon(Icons.apartment_outlined),
                      ),
                      items: [
                        for (final entry in InstitucionTypes.labels.entries)
                          DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _tipo = v);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Programa Pequeños Ingenieros'),
                      subtitle: const Text('Añade componentes extra al '
                          'registrar equipos'),
                      value: _pequenosIngenieros,
                      onChanged: (v) =>
                          setState(() => _pequenosIngenieros = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),
              Wrap(
                spacing: AppDimens.lg,
                runSpacing: AppDimens.lg,
                children: [
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      label: 'Dirección (opcional)',
                      prefixIcon: const Icon(Icons.place_outlined),
                      controller: _direccionCtrl,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: AppTextField(
                      label: 'Teléfono (opcional)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      controller: _telefonoCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              PrimaryButton(
                label: 'Registrar Institución',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        _InstitucionesList(
          onDelete: _delete,
          onSelect: _seleccionar,
        ),
      ],
    );
  }
}

class _InstitucionesList extends StatelessWidget {
  const _InstitucionesList({required this.onDelete, required this.onSelect});

  final ValueChanged<Institucion> onDelete;
  final ValueChanged<Institucion> onSelect;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final activeId = context.watch<InstituccionProvider>().activeId;
    return SectionCard(
      title: 'Instituciones registradas',
      icon: Icons.account_balance_outlined,
      child: StreamBuilder(
        stream: firestore.watch(kInstitucionesCollection, orderBy: 'nombre'),
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
          final instituciones = snapshot.data!.docs
              .map((d) => Institucion.fromMap({...d.data(), 'id': d.id}))
              .toList();
          if (instituciones.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_outlined,
              title: 'Sin instituciones',
              description: 'Registre la primera institución para comenzar '
                  'a trabajar con espacios independientes.',
            );
          }
          return Column(
            children: [
              for (final institucion in instituciones)
                _InstitucionTile(
                  institucion: institucion,
                  isActive: institucion.id == activeId,
                  onSelect: () => onSelect(institucion),
                  onDelete: () => onDelete(institucion),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InstitucionTile extends StatelessWidget {
  const _InstitucionTile({
    required this.institucion,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
  });

  final Institucion institucion;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? scheme.primary
              : scheme.primaryContainer,
          child: Icon(
            Icons.account_balance_outlined,
            color: isActive ? scheme.onPrimary : scheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                institucion.nombre,
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: AppDimens.sm),
              Chip(
                label: const Text('Activa'),
                visualDensity: VisualDensity.compact,
                backgroundColor: scheme.primaryContainer,
                labelStyle: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${institucion.tipoLabel}'
              '${institucion.pequenosIngenieros ? ' · Pequeños Ingenieros' : ''}',
            ),
            if (institucion.direccion.isNotEmpty ||
                institucion.telefono.isNotEmpty)
              Text(
                [institucion.direccion, institucion.telefono]
                    .where((x) => x.isNotEmpty)
                    .join(' · '),
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Usar esta institución',
              icon: const Icon(Icons.play_arrow_outlined),
              onPressed: onSelect,
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              color: scheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}