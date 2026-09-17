import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import 'collection_list.dart';
import 'entity_form.dart';
import 'form_specs.dart';

/// Módulo heredado de prácticas de programación (catálogo global).
class PracticasLegacyView extends StatelessWidget {
  const PracticasLegacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntityForm(
          collection: kPracticasCollection,
          fields: FormSpecs.practica,
          submitLabel: 'Registrar Práctica',
        ),
        const SizedBox(height: AppDimens.xl),
        CollectionList(
          collection: kPracticasCollection,
          title: 'Prácticas registradas',
          columns: const [
            ListColumn('titulo', 'Título'),
            ListColumn('materia', 'Materia'),
            ListColumn('lenguaje', 'Lenguaje'),
            ListColumn('dificultad', 'Dificultad'),
          ],
        ),
      ],
    );
  }
}