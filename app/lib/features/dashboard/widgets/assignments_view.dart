import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/app_user.dart';
import '../../../services/firestore_service.dart';

/// Asignación de estudiantes a equipos del laboratorio.
class AssignmentsView extends StatefulWidget {
  const AssignmentsView({super.key});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  final _formKey = GlobalKey<FormState>();
  final _fecha = TextEditingController();
  final _observacion = TextEditingController();
  String? _studentUid;
  String? _equipoCodigo;
  bool _saving = false;

  @override
  void dispose() {
    _fecha.dispose();
    _observacion.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final firestore = context.read<FirestoreService>();
      final students = await firestore.getAll(
        kUsuariosCollection,
        filters: const [QueryFilter('tipo', UserRoles.estudiante)],
      );
      final match = students.firstWhere(
        (m) => m['uid'] == _studentUid,
        orElse: () => const <String, dynamic>{},
      );
      await firestore.add(kAsignacionesCollection, {
        'estudianteUid': _studentUid,
        'estudianteNombre':
            '${match['nombre'] ?? ''} ${match['apellido'] ?? ''}'.trim(),
        'estudianteCedula': match['cedula'] ?? '',
        'equipoCodigo': _equipoCodigo,
        'fecha': _fecha.text.trim(),
        'observacion': _observacion.text.trim(),
        'creadoEn': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      _fecha.clear();
      _observacion.clear();
      setState(() {
        _studentUid = null;
        _equipoCodigo = null;
      });
      AppSnackbar.success(context, 'Asignación registrada correctamente.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al asignar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder(
          stream: firestore.watch(
            kUsuariosCollection,
            filters: const [QueryFilter('tipo', UserRoles.estudiante)],
          ),
          builder: (context, userSnapshot) {
            return StreamBuilder(
              stream: firestore.watch(kEquiposCollection),
              builder: (context, equipoSnapshot) {
                final students = (userSnapshot.data?.docs ?? [])
                    .map((d) => AppUser.fromFirestore(d.data()))
                    .toList();
                final equipos = (equipoSnapshot.data?.docs ?? [])
                    .map((d) => d.data())
                    .toList();
                return _buildForm(students, equipos);
              },
            );
          },
        ),
        const SizedBox(height: AppDimens.xl),
        const _AssignmentsList(),
      ],
    );
  }

  Widget _buildForm(List<AppUser> students, List<Map<String, dynamic>> equipos) {
    final studentValue =
        students.any((s) => s.uid == _studentUid) ? _studentUid : null;
    final equipoValue = equipos.any(
      (e) => e['codigo']?.toString() == _equipoCodigo,
    )
        ? _equipoCodigo
        : null;

    return SectionCard(
      title: 'Asignar estudiante a equipo',
      icon: Icons.link_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn = constraints.maxWidth >= 560;
                final halfWidth = (constraints.maxWidth - AppDimens.lg) / 2;
                Widget field(Widget child, {bool full = false}) => SizedBox(
                      width:
                          twoColumn && !full ? halfWidth : constraints.maxWidth,
                      child: child,
                    );
                return Wrap(
                  spacing: AppDimens.lg,
                  runSpacing: AppDimens.lg,
                  children: [
                    field(DropdownButtonFormField<String>(
                      key: ValueKey('student-$studentValue'),
                      initialValue: studentValue,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Estudiante',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: students
                          .map((s) => DropdownMenuItem(
                                value: s.uid,
                                child: Text(
                                  '${s.nombreCompleto} — ${s.cedula}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Seleccione un estudiante'
                          : null,
                      onChanged: (v) => setState(() => _studentUid = v),
                    )),
                    field(DropdownButtonFormField<String>(
                      key: ValueKey('equipo-$equipoValue'),
                      initialValue: equipoValue,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Equipo',
                        prefixIcon: Icon(Icons.devices_outlined),
                      ),
                      items: equipos
                          .map((e) => DropdownMenuItem(
                                value: e['codigo']?.toString(),
                                child: Text(
                                  '${e['codigo'] ?? ''} — ${e['tipo'] ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Seleccione un equipo' : null,
                      onChanged: (v) => setState(() => _equipoCodigo = v),
                    )),
                    field(AppTextField(
                      label: 'Fecha',
                      controller: _fecha,
                      hint: 'Ej: 2026-09-16',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    )),
                    field(AppTextField(
                      label: 'Observación (opcional)',
                      controller: _observacion,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: AppDimens.md),
            PrimaryButton(
              label: 'Asignar Equipo',
              icon: Icons.link_outlined,
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Listado en vivo de las asignaciones registradas.
class _AssignmentsList extends StatelessWidget {
  const _AssignmentsList();

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Asignaciones registradas',
      icon: Icons.assignment_turned_in_outlined,
      child: StreamBuilder(
        stream: firestore.watch(kAsignacionesCollection),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return ErrorState(message: '${snapshot.error}');
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              title: 'Sin asignaciones',
              description: 'Todavía no se ha asignado ningún equipo.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${docs.length} registros',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppDimens.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Estudiante')),
                    DataColumn(label: Text('Cédula')),
                    DataColumn(label: Text('Equipo')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('')),
                  ],
                  rows: docs.map((doc) {
                    final data = doc.data();
                    return DataRow(cells: [
                      DataCell(Text('${data['estudianteNombre'] ?? '-'}')),
                      DataCell(Text('${data['estudianteCedula'] ?? '-'}')),
                      DataCell(Text('${data['equipoCodigo'] ?? '-'}')),
                      DataCell(Text('${data['fecha'] ?? '-'}')),
                      DataCell(IconButton(
                        tooltip: 'Eliminar asignación',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            firestore.delete(kAsignacionesCollection, doc.id),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
