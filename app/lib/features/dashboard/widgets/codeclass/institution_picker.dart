import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../models/codeclass_models.dart';
import '../../../../providers/instituccion_provider.dart';
import '../../../../services/firestore_service.dart';

/// Selector de institución activa usado en Registro, Teoría y Práctica.
class InstitutionPicker extends StatelessWidget {
  const InstitutionPicker({super.key, this.onChanged});

  final ValueChanged<Institucion?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return StreamBuilder(
      stream: firestore.watch(kInstitucionesCollection, orderBy: 'nombre'),
      builder: (context, snapshot) {
        final instituciones = snapshot.data?.docs
                .map((d) => Institucion.fromMap({...d.data(), 'id': d.id}))
                .toList() ??
            const <Institucion>[];
        final provider = context.watch<InstituccionProvider>();
        return DropdownButtonFormField<String>(
          key: ValueKey('institution-${provider.activeId}'),
          initialValue: provider.activeId,
          decoration: InputDecoration(
            labelText: 'Institución',
            prefixIcon: const Icon(Icons.account_balance_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('— Sin institución seleccionada —'),
            ),
            for (final i in instituciones)
              DropdownMenuItem(value: i.id, child: Text(i.nombre)),
          ],
          onChanged: (value) {
            final selected = instituciones
                .where((i) => i.id == value)
                .firstOrNull;
            provider.select(selected);
            onChanged?.call(selected);
          },
        );
      },
    );
  }
}