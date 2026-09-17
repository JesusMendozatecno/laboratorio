import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../services/firestore_service.dart';

/// Tipo de campo soportado por [EntityForm].
enum FieldType { text, number, dropdown, multiline }

/// Definición de un campo del formulario.
class FieldSpec {
  const FieldSpec({
    required this.key,
    required this.label,
    this.type = FieldType.text,
    this.required = true,
    this.options = const [],
    this.icon,
    this.hint,
  });

  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final List<String> options;
  final IconData? icon;
  final String? hint;
}

/// Formulario genérico que guarda documentos en una colección de Firestore.
///
/// Los campos se distribuyen a dos columnas cuando el espacio lo permite.
class EntityForm extends StatefulWidget {
  const EntityForm({
    super.key,
    required this.collection,
    required this.fields,
    required this.submitLabel,
    this.onSaved,
  });

  final String collection;
  final List<FieldSpec> fields;
  final String submitLabel;
  final VoidCallback? onSaved;

  @override
  State<EntityForm> createState() => _EntityFormState();
}

class _EntityFormState extends State<EntityForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      if (field.type == FieldType.dropdown) {
        _dropdownValues[field.key] =
            field.options.isNotEmpty ? field.options.first : '';
      } else {
        _controllers[field.key] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'creadoEn': DateTime.now().toIso8601String(),
      };
      for (final field in widget.fields) {
        if (field.type == FieldType.dropdown) {
          data[field.key] = _dropdownValues[field.key];
        } else {
          final raw = _controllers[field.key]!.text.trim();
          data[field.key] =
              field.type == FieldType.number ? (num.tryParse(raw) ?? raw) : raw;
        }
      }
      await context.read<FirestoreService>().add(widget.collection, data);
      if (!mounted) return;
      for (final c in _controllers.values) {
        c.clear();
      }
      AppSnackbar.success(context, 'Registro guardado correctamente.');
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: widget.submitLabel,
      icon: Icons.edit_note,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn = constraints.maxWidth >= 560;
                final halfWidth =
                    (constraints.maxWidth - AppDimens.lg) / 2;
                return Wrap(
                  spacing: AppDimens.lg,
                  runSpacing: AppDimens.lg,
                  children: [
                    for (final field in widget.fields)
                      SizedBox(
                        width: field.type == FieldType.multiline || !twoColumn
                            ? constraints.maxWidth
                            : halfWidth,
                        child: _buildField(field),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppDimens.md),
            PrimaryButton(
              label: widget.submitLabel,
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FieldSpec field) {
    switch (field.type) {
      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: _dropdownValues[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            prefixIcon: field.icon != null ? Icon(field.icon) : null,
          ),
          items: field.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          validator: field.required
              ? (v) => (v == null || v.isEmpty) ? 'Seleccione una opción' : null
              : null,
          onChanged: (v) =>
              setState(() => _dropdownValues[field.key] = v ?? ''),
        );
      case FieldType.multiline:
        return AppTextField(
          label: field.label,
          controller: _controllers[field.key],
          hint: field.hint,
          prefixIcon: field.icon != null ? Icon(field.icon) : null,
          maxLines: 4,
          minLines: 3,
          validator: field.required ? (v) => _required(v) : null,
        );
      case FieldType.number:
      case FieldType.text:
        return AppTextField(
          label: field.label,
          controller: _controllers[field.key],
          hint: field.hint,
          keyboardType: field.type == FieldType.number
              ? TextInputType.number
              : TextInputType.text,
          prefixIcon: field.icon != null ? Icon(field.icon) : null,
          validator: field.required ? (v) => _required(v) : null,
        );
    }
  }

  String? _required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Campo requerido' : null;
  }
}