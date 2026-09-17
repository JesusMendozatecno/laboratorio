import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_provider.dart';

/// Aplica la seguridad local a la zona autenticada de la aplicación:
/// bloquea la interfaz con huella/PIN al volver del segundo plano.
class SecurityGate extends StatefulWidget {
  const SecurityGate({super.key, required this.child});

  final Widget child;

  @override
  State<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends State<SecurityGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final security = context.read<SecurityProvider>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        security.lock();
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    return Stack(
      children: [
        widget.child,
        if (security.isLocked) const Positioned.fill(child: LockOverlay()),
      ],
    );
  }
}

/// Capa que cubre la aplicación mientras está bloqueada.
class LockOverlay extends StatefulWidget {
  const LockOverlay({super.key});

  @override
  State<LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<LockOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  Future<void> _tryUnlock() async {
    if (!mounted) return;
    await context.read<SecurityProvider>().unlock();
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 42,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  Text(
                    'Aplicación bloqueada',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    'Verifica tu identidad con tu huella o PIN para continuar.',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.xxl),
                  PrimaryButton(
                    label: 'Desbloquear',
                    icon: Icons.fingerprint,
                    isLoading: security.unlocking,
                    onPressed: _tryUnlock,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  SecondaryButton(
                    label: 'Cerrar sesión',
                    icon: Icons.logout,
                    onPressed: security.unlocking
                        ? null
                        : () => context.read<AuthProvider>().logout(),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Text(
                    AppStrings.appName,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
