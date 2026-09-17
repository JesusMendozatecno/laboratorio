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
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

/// Registro y listado de estudiantes.
///
/// Crea la cuenta en Firebase Auth (mediante una instancia secundaria para no
/// cerrar la sesión del administrador) y guarda el perfil en Firestore.
class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _cedula = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _cedula, _correo, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo requerido' : null;

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Campo requerido';
    if (!text.contains('@') || !text.contains('.')) {
      return 'Correo no válido';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final auth = context.read<AuthService>();
      final firestore = context.read<FirestoreService>();
      final credential =
          await auth.createAccountFor(_correo.text, _password.text);
      final user = AppUser(
        uid: credential.user!.uid,
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        cedula: _cedula.text.trim(),
        correo: _correo.text.trim(),
        tipo: UserRoles.estudiante,
      );
      await firestore.saveUser(user);
      if (!mounted) return;
      for (final c in [_nombre, _apellido, _cedula, _correo, _password]) {
        c.clear();
      }
      AppSnackbar.success(context, 'Estudiante registrado correctamente.');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, AuthService.messageFrom(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Registrar estudiante',
          icon: Icons.person_add_alt_1_outlined,
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
                          width: twoColumn && !full
                              ? halfWidth
                              : constraints.maxWidth,
                          child: child,
                        );
                    return Wrap(
                      spacing: AppDimens.lg,
                      runSpacing: AppDimens.lg,
                      children: [
                        field(AppTextField(
                          label: 'Nombre',
                          controller: _nombre,
                          prefixIcon: const Icon(Icons.person_outline),
                          textCapitalization: TextCapitalization.words,
                          validator: _required,
                        )),
                        field(AppTextField(
                          label: 'Apellido',
                          controller: _apellido,
                          prefixIcon: const Icon(Icons.person_outline),
                          textCapitalization: TextCapitalization.words,
                          validator: _required,
                        )),
                        field(AppTextField(
                          label: 'Cédula',
                          controller: _cedula,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.credit_card),
                          validator: _required,
                        )),
                        field(AppTextField(
                          label: 'Correo',
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          autocorrect: false,
                          validator: _emailValidator,
                        )),
                        field(AppTextField(
                          label: 'Contraseña',
                          controller: _password,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: _passwordValidator,
                        )),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimens.md),
                PrimaryButton(
                  label: 'Registrar Estudiante',
                  icon: Icons.person_add_alt_1_outlined,
                  isLoading: _saving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        const _StudentsList(),
      ],
    );
  }
}

/// Listado en vivo de los estudiantes registrados.
class _StudentsList extends StatelessWidget {
  const _StudentsList();

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return SectionCard(
      title: 'Estudiantes registrados',
      icon: Icons.groups_outlined,
      child: StreamBuilder(
        stream: firestore.watch(
          kUsuariosCollection,
          filters: const [QueryFilter('tipo', UserRoles.estudiante)],
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
              title: 'Sin estudiantes',
              description: 'Aún no hay estudiantes registrados.',
            );
          }
          final students = docs
              .map((d) => AppUser.fromFirestore(d.data()))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${students.length} registros',
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
                  ],
                  rows: students
                      .map((s) => DataRow(cells: [
                            DataCell(Text(s.nombreCompleto)),
                            DataCell(Text(s.cedula)),
                            DataCell(Text(s.correo)),
                          ]))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
