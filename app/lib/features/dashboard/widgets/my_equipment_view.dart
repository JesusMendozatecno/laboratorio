import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/app_user.dart';
import '../../../services/firestore_service.dart';

/// Equipos asignados al estudiante que tiene la sesión iniciada.
class MyEquipmentView extends StatelessWidget {
  const MyEquipmentView({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Mis equipos asignados',
      icon: Icons.devices_other_outlined,
      child: StreamBuilder(
        stream: firestore.watch(
          kAsignacionesCollection,
          filters: [QueryFilter('estudianteUid', user.uid)],
        ),
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
              icon: Icons.devices_other_outlined,
              title: 'Sin equipos asignados',
              description:
                  'Aún no tienes equipos asignados por el encargado del '
                  'laboratorio.',
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Equipo')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Observación')),
              ],
              rows: docs.map((doc) {
                final data = doc.data();
                return DataRow(cells: [
                  DataCell(Text('${data['equipoCodigo'] ?? '-'}')),
                  DataCell(Text('${data['fecha'] ?? '-'}')),
                  DataCell(Text('${data['observacion'] ?? '-'}')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
