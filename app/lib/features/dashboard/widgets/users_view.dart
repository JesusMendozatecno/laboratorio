import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/app_user.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';

/// Gestión de usuarios: consulta, cambio de rol y eliminación.
class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final currentUid = context.watch<AuthProvider>().user?.uid;

    return SectionCard(
      title: 'Usuarios del sistema',
      icon: Icons.manage_accounts_outlined,
      child: StreamBuilder(
        stream: firestore.watch(kUsuariosCollection),
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
              title: 'Sin usuarios',
              description: 'No se encontraron usuarios registrados.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${docs.length} usuarios',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppDimens.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Cédula')),
                    DataColumn(label: Text('Correo')),
                    DataColumn(label: Text('Rol')),
                    DataColumn(label: Text('')),
                  ],
                  rows: docs.map((doc) {
                    final user = AppUser.fromFirestore(doc.data());
                    final isSelf = user.uid == currentUid;
                    return DataRow(cells: [
                      DataCell(Text(user.nombreCompleto)),
                      DataCell(Text(user.cedula)),
                      DataCell(Text(user.correo)),
                      DataCell(_RoleChip(tipo: user.tipo)),
                      DataCell(
                        isSelf
                            ? const Text('—')
                            : _UserActions(user: user),
                      ),
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

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.tipo});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEncargado = tipo == UserRoles.encargado;
    final isDocente = tipo == UserRoles.docente;
    final bg = isEncargado
        ? scheme.primaryContainer
        : isDocente
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest;
    final fg = isEncargado
        ? scheme.onPrimaryContainer
        : isDocente
            ? scheme.onSecondaryContainer
            : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        UserRoles.labels[tipo] ?? tipo,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _UserActions extends StatelessWidget {
  const _UserActions({required this.user});

  final AppUser user;

  Future<void> _changeRole(BuildContext context, String role) async {
    final firestore = context.read<FirestoreService>();
    try {
      await firestore.update(kUsuariosCollection, user.uid, {'tipo': role});
      if (!context.mounted) return;
      AppSnackbar.success(
        context,
        '${user.nombreCompleto} ahora es ${UserRoles.labels[role]}.',
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.error(context, 'No se pudo cambiar el rol: $e');
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Eliminar usuario',
      message:
          'Se eliminará el perfil de ${user.nombreCompleto}. Esta acción no '
          'elimina su cuenta de acceso.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    final firestore = context.read<FirestoreService>();
    try {
      await firestore.delete(kUsuariosCollection, user.uid);
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Perfil eliminado.');
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.error(context, 'No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Acciones',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'delete') {
          _delete(context);
        } else {
          _changeRole(context, value);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(enabled: false, child: Text('Cambiar rol')),
        for (final entry in UserRoles.labels.entries)
          CheckedPopupMenuItem(
            value: entry.key,
            checked: user.tipo == entry.key,
            child: Text(entry.value),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Eliminar perfil'),
        ),
      ],
    );
  }
}
