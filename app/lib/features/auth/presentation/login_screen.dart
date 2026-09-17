import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_identifierCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    AppSnackbar.error(context, auth.error ?? 'No se pudo iniciar sesión');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Inicie sesión para continuar',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Cédula o correo',
              controller: _identifierCtrl,
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingrese su cédula o correo'
                  : null,
            ),
            const SizedBox(height: AppDimens.lg),
            AppTextField(
              label: 'Contraseña',
              controller: _passwordCtrl,
              prefixIcon: const Icon(Icons.lock_outline),
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingrese su contraseña' : null,
            ),
            const SizedBox(height: AppDimens.xl),
            PrimaryButton(
              label: 'Entrar',
              icon: Icons.login,
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: AppDimens.sm),
            TextButton(
              onPressed: auth.isBusy
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
              child: const Text('¿No tienes cuenta? Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}