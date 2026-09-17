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
import '../../../../services/firestore_service.dart';

/// CC-REG-01 — Registro de materias (catálogo reutilizable).
class MateriasView extends StatefulWidget {
  const MateriasView({super.key});

  @override
  State<MateriasView> createState() => _MateriasViewState();
}

class _MateriasViewState extends State<MateriasView> {
  final _controller = TextEditingController();
  String _query = '';
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nombre = _controller.text.trim();
    if (nombre.isEmpty) {
      AppSnackbar.error(context, 'Escriba el nombre de la materia.');
      return;
    }
    setState(() => _saving = true);
    try {
      final firestore = context.read<FirestoreService>();
      final existentes = await firestore.getAll(kMateriasCollection);
      final duplicada = existentes.any((m) =>
          ((m['nombre'] as String? ?? '').toLowerCase()) ==
          nombre.toLowerCase());
      if (duplicada) {
        if (!mounted) return;
        AppSnackbar.error(context, 'Esa materia ya está registrada.');
        setState(() => _saving = false);
        return;
      }
      await firestore.add(kMateriasCollection, {
        'nombre': nombre,
        'creadoEn': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      _controller.clear();
      AppSnackbar.success(context, 'Materia registrada.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(Materia materia) async {
    final firestore = context.read<FirestoreService>();
    final ok = await AppDialog.confirm(
      context,
      title: 'Eliminar materia',
      message: '¿Eliminar "${materia.nombre}"? Las clases que la usan '
          'conservarán el nombre guardado.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (ok != true) return;
    try {
      await firestore.delete(
            kMateriasCollection,
            materia.id,
          );
      if (!mounted) return;
      AppSnackbar.success(context, 'Materia eliminada.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Registrar materia',
          icon: Icons.menu_book_outlined,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Nombre de la materia',
                  hint: 'Ej: ITP, Programación I, Programación II…',
                  prefixIcon: const Icon(Icons.menu_book_outlined),
                  controller: _controller,
                  onFieldSubmitted: (_) => _save(),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo requerido'
                          : null,
                ),
                const SizedBox(height: AppDimens.md),
                PrimaryButton(
                  label: 'Registrar Materia',
                  icon: Icons.save_outlined,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        _MateriasList(query: _query, onQueryChanged: (q) {
          setState(() => _query = q);
        }, onDelete: _delete),
      ],
    );
  }
}

class _MateriasList extends StatelessWidget {
  const _MateriasList({
    required this.query,
    required this.onQueryChanged,
    required this.onDelete,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Materia> onDelete;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Materias registradas',
      icon: Icons.list_alt_outlined,
      child: StreamBuilder(
        stream: firestore.watch(kMateriasCollection, orderBy: 'nombre'),
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
          final materias = snapshot.data!.docs
              .map((d) => Materia.fromMap({...d.data(), 'id': d.id}))
              .where((m) => query.isEmpty ||
                  m.nombre.toLowerCase().contains(query.toLowerCase()))
              .toList();
          if (materias.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Sin materias',
              description: query.isEmpty
                  ? 'Registre la primera materia.'
                  : 'No hay materias que coincidan con la búsqueda.',
            );
          }
          return Column(
            children: [
              _SearchField(query: query, onChanged: onQueryChanged),
              const SizedBox(height: AppDimens.sm),
              for (final materia in materias)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(materia.nombre),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => onDelete(materia),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Campo de búsqueda compacto reutilizado en listas largas.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.query, required this.onChanged});

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Buscar…',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}