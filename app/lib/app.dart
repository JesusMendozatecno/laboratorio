import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_shell.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/security/security_gate.dart';
import 'providers/auth_provider.dart';
import 'providers/instituccion_provider.dart';
import 'providers/security_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

/// Aplicación principal con los providers globales y el tema.
class LaboratorioApp extends StatelessWidget {
  const LaboratorioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<SecurityProvider>(
          create: (_) => SecurityProvider()..init(),
        ),
        ChangeNotifierProvider<InstituccionProvider>(
          create: (_) => InstituccionProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightFor(theme.brand),
            darkTheme: AppTheme.darkFor(theme.brand),
            themeMode: theme.mode,
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: child!,
            ),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// Decide la pantalla raíz según el estado de la sesión.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const HomeScreen();
      case AuthStatus.authenticated:
        return const SecurityGate(child: DashboardShell());
    }
  }
}