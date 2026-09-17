import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';
import '../settings_view.dart';

/// CC-NAV-05 — Usuario: perfil, apariencia, seguridad e información de la app.
class UsuarioView extends StatelessWidget {
  const UsuarioView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsView(),
        SizedBox(height: 16),
        SectionCard(
          title: 'Ayuda',
          icon: Icons.help_outline,
          child: Text(
            'CodeClass es un sistema de gestión de clases de programación. '
            'Usa el menú lateral para crear instituciones y administrar '
            'usuarios, asignaciones, prácticas y reportes.',
          ),
        ),
      ],
    );
  }
}