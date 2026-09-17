import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import 'collection_list.dart';
import 'entity_form.dart';
import 'form_specs.dart';

/// Módulo heredado de reportes: crear y consultar novedades.
class ReportesView extends StatelessWidget {
  const ReportesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntityForm(
          collection: kReportesCollection,
          fields: FormSpecs.reporte,
          submitLabel: 'Crear Reporte',
        ),
        const SizedBox(height: AppDimens.xl),
        CollectionList(
          collection: kReportesCollection,
          title: 'Reportes registrados',
          emptyMessage: 'Aún no hay reportes.',
          columns: const [
            ListColumn('descripcion', 'Descripción'),
            ListColumn('creadoEn', 'Fecha'),
          ],
        ),
      ],
    );
  }
}