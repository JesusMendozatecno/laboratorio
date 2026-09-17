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

/// Componentes básicos de todo equipo.
const List<String> kComponentesBasicos = ['Monitor', 'Teclado', 'Mouse'];

/// Componentes adicionales del programa Pequeños Ingenieros.
const List<String> kComponentesPI = [
  'Tarjeta Pequeños Ingenieros',
  'Cable USB Tipo C',
];

/// CC-REG-04 — Registro de equipos por institución.
class EquiposView extends StatefulWidget {
  const EquiposView({super.key});

  @override
  State<EquiposView> createState() => _EquiposViewState();
}

class _EquiposViewState extends State<EquiposView> {
  final _codigoCtrl = TextEditingController();
  final Map<String, bool> _tiene = {};
  final Map<String, TextEditingController> _serialCtrl = {};
  bool _saving = false;

  Institucion? get _institucion => context.watch<InstituccionProvider>().active;

  List<String> get _componentes {
    final i = _institucion;
    return [
      ...kComponentesBasicos,
      if (i?.pequenosIngenieros ?? false) ...kComponentesPI,
    ];
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    for (final c in _serialCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _buildSerialControllers() {
    for (final c in _componentes) {
      _serialCtrl.putIfAbsent(c, TextEditingController.new);
    }
  }

  Future<void> _save() async {
    final institucion = _institucion;
    if (institucion == null) return;
    _buildSerialControllers();
    setState(() => _saving = true);
    try {
      final firestore = context.read<FirestoreService>();
      final existentes = await firestore.getAll(
        kEquiposCollection,
        filters: [QueryFilter('institucionId', institucion.id)],
      );
      final codigo = _codigoCtrl.text.trim().isNotEmpty
          ? _codigoCtrl.text.trim()
          : 'Equipo ${existentes.length + 1}';
      final componentes = <String, Map<String, dynamic>>{};
      for (final c in _componentes) {
        final tiene = _tiene[c] ?? false;
        final serial = _serialCtrl[c]?.text.trim() ?? '';
        componentes[c] = {'tiene': tiene, 'serial': serial};
      }
      await firestore.add(
        kEquiposCollection,
        Equipo(
          institucionId: institucion.id,
          codigo: codigo,
          componentes: componentes,
          creadoEn: DateTime.now().toIso8601String(),
        ).toMap(),
      );
      if (!mounted) return;
      _codigoCtrl.clear();
      setState(() {
        _tiene.clear();
        for (final c in _serialCtrl.values) {
          c.clear();
        }
      });
      AppSnackbar.success(context, 'Equipo registrado.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(Equipo equipo) async {
    final firestore = context.read<FirestoreService>();
    final ok = await AppDialog.confirm(
      context,
      title: 'Eliminar equipo',
      message: '¿Eliminar "${equipo.codigo}"?',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (ok != true) return;
    try {
      await firestore
          .delete(kEquiposCollection, equipo.id);
      if (!mounted) return;
      AppSnackbar.success(context, 'Equipo eliminado.');
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
        title: 'Equipos',
        icon: Icons.devices_outlined,
        child: EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Selecciona una institución',
          description: 'Los equipos pertenecen a una institución.',
        ),
      );
    }
    final componentes = _componentes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Registrar equipo — ${institucion.nombre}',
          icon: Icons.devices_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 320,
                child: AppTextField(
                  label: 'Código (opcional)',
                  hint: 'Deje vacío para auto-asignar "Equipo N"',
                  prefixIcon: const Icon(Icons.tag),
                  controller: _codigoCtrl,
                ),
              ),
              const SizedBox(height: AppDimens.lg),
              Text(
                'Componentes: marque "Tiene" para cada componente presente '
                'y escriba su serial cuando corresponda.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppDimens.md),
              for (final componente in componentes)
                _ComponenteEditor(
                  nombre: componente,
                  tiene: _tiene[componente] ?? false,
                  serialCtrl:
                      _serialCtrl.putIfAbsent(componente, TextEditingController.new),
                  onToggle: (v) => setState(() => _tiene[componente] = v),
                ),
              const SizedBox(height: AppDimens.md),
              const Divider(),
              const SizedBox(height: AppDimens.md),
              PrimaryButton(
                label: 'Registrar Equipo',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        _EquiposLista(
          institucion: institucion,
          onDelete: _delete,
        ),
      ],
    );
  }
}

class _ComponenteEditor extends StatelessWidget {
  const _ComponenteEditor({
    required this.nombre,
    required this.tiene,
    required this.serialCtrl,
    required this.onToggle,
  });

  final String nombre;
  final bool tiene;
  final TextEditingController serialCtrl;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tiene ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: tiene ? Colors.green.shade600 : scheme.outline,
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Text(
                    nombre,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Switch(value: tiene, onChanged: onToggle),
                Text(tiene ? 'Tiene' : 'No tiene',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            if (tiene) ...[
              const SizedBox(height: AppDimens.sm),
              AppTextField(
                label: 'Serial de $nombre (opcional)',
                prefixIcon: const Icon(Icons.qr_code_outlined),
                controller: serialCtrl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EquiposLista extends StatelessWidget {
  const _EquiposLista({required this.institucion, required this.onDelete});

  final Institucion institucion;
  final ValueChanged<Equipo> onDelete;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Equipos de ${institucion.nombre}',
      icon: Icons.devices_outlined,
      child: StreamBuilder(
        stream: firestore.watch(
          kEquiposCollection,
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
          final equipos = snapshot.data!.docs
              .map((d) => Equipo.fromMap({...d.data(), 'id': d.id}))
              .toList();
          if (equipos.isEmpty) {
            return EmptyState(
              icon: Icons.devices_outlined,
              title: 'Sin equipos',
              description: 'Registre el primer equipo de esta institución.',
            );
          }
          return Column(
            children: [
              for (final equipo in equipos)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: AppDimens.xs),
                  child: ListTile(
                    leading: const Icon(Icons.computer_outlined),
                    title: Text(
                      equipo.codigo,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Wrap(
                      spacing: AppDimens.xs,
                      runSpacing: AppDimens.xs,
                      children: [
                        for (final c in equipo.componentes.keys)
                          Chip(
                            avatar: Icon(
                              equipo.tiene(c)
                                  ? Icons.check_circle
                                  : Icons.remove_circle_outline,
                              size: 16,
                              color: equipo.tiene(c)
                                  ? Colors.green.shade600
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            label: Text('$c'
                                '${equipo.serialDe(c).isNotEmpty ? " · ${equipo.serialDe(c)}" : ''}'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => onDelete(equipo),
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