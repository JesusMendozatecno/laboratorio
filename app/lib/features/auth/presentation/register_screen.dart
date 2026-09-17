import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _tipo = UserRoles.estudiante;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _cedulaCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      nombre: _nombreCtrl.text,
      apellido: _apellidoCtrl.text,
      cedula: _cedulaCtrl.text,
      correo: _correoCtrl.text,
      password: _passCtrl.text,
      tipo: _tipo,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      AppSnackbar.success(context, 'Registro exitoso. Bienvenido.');
    } else {
      AppSnackbar.error(context, auth.error ?? 'Error al registrar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Cree su cuenta',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Nombre',
              controller: _nombreCtrl,
              prefixIcon: const Icon(Icons.badge_outlined),
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, 'Ingrese su nombre'),
            ),
            const SizedBox(height: AppDimens.lg),
            AppTextField(
              label: 'Apellido',
              controller: _apellidoCtrl,
              prefixIcon: const Icon(Icons.badge_outlined),
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, 'Ingrese su apellido'),
            ),
            const SizedBox(height: AppDimens.lg),
            AppTextField(
              label: 'Cédula',
              controller: _cedulaCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.credit_card_outlined),
              textInputAction: TextInputAction.next,
              validator: Validators.cedula,
            ),
            const SizedBox(height: AppDimens.lg),
            AppTextField(
              label: 'Correo',
              controller: _correoCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: AppDimens.lg),
            AppTextField(
              label: 'Contraseña',
              controller: _passCtrl,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline),
              textInputAction: TextInputAction.next,
              validator: Validators.password,
            ),
            const SizedBox(height: AppDimens.lg),
            AppTextField(
              label: 'Confirmar contraseña',
              controller: _confirmCtrl,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_reset),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
            ),
            const SizedBox(height: AppDimens.lg),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de usuario',
                prefixIcon: Icon(Icons.supervisor_account_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: UserRoles.estudiante,
                  child: Text('Estudiante'),
                ),
                DropdownMenuItem(
                  value: UserRoles.docente,
                  child: Text('Docente'),
                ),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? UserRoles.estudiante),
            ),
            const SizedBox(height: AppDimens.xl),
            PrimaryButton(
              label: 'Registrar',
              icon: Icons.person_add_alt_1,
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: AppDimens.sm),
            TextButton(
              onPressed: auth.isBusy
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('¿Ya tienes cuenta? Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}