import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/section_card.dart';
import '../../../services/firestore_service.dart';

/// Columna mostrada en [CollectionList].
class ListColumn {
  const ListColumn(this.key, this.label);

  final String key;
  final String label;
}

/// Lista en vivo de documentos de una colección de Firestore.
///
/// Incluye estados de carga, error y vacío, y una tabla con scroll horizontal
/// para pantallas angostas.
class CollectionList extends StatelessWidget {
  const CollectionList({
    super.key,
    required this.collection,
    required this.columns,
    this.title,
    this.emptyMessage = 'No hay registros todavía.',
    this.orderBy,
  });

  final String collection;
  final List<ListColumn> columns;
  final String? title;
  final String emptyMessage;
  final String? orderBy;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: title,
      icon: Icons.list_alt_outlined,
      child: StreamBuilder(
        stream: firestore.watch(collection, orderBy: orderBy),
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
            return EmptyState(
              title: 'Sin registros',
              description: emptyMessage,
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
                  columns: columns
                      .map((c) => DataColumn(label: Text(c.label)))
                      .toList(),
                  rows: docs.map((doc) {
                    final data = doc.data();
                    return DataRow(
                      cells: columns
                          .map((c) => DataCell(Text(_display(data[c.key]))))
                          .toList(),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _display(Object? value) {
    if (value == null) return '-';
    if (value is String && value.length > 28) {
      return '${value.substring(0, 28)}…';
    }
    return value.toString();
  }
}