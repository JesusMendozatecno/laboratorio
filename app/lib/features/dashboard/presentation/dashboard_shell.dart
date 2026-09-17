import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/page_title.dart';
import '../../../models/app_user.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/assignments_view.dart';
import '../widgets/codeclass/inicio_codeclass_view.dart';
import '../widgets/codeclass/instituciones_view.dart';
import '../widgets/codeclass/practica_view.dart';
import '../widgets/codeclass/registro_view.dart';
import '../widgets/codeclass/teoria_view.dart';
import '../widgets/codeclass/usuario_view.dart';
import '../widgets/inicio_view.dart';
import '../widgets/my_equipment_view.dart';
import '../widgets/practicas_legacy_view.dart';
import '../widgets/reportes_view.dart';
import '../widgets/users_view.dart';
import 'dashboard_layout.dart';

/// Panel principal CodeClass.
///
/// - Pestañas inferiores (Inicio, Registro, Teoría, Práctica, Usuario,
///   Asignaciones, Prácticas, Reportes).
/// - Menú lateral para el catálogo (Instituciones) y usuarios.
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DashboardLayout(
      user: user,
      onLogout: () => context.read<AuthProvider>().logout(),
      pages: user.tipo == UserRoles.estudiante
          ? _pagesEstudiante(user)
          : _pagesDocente(user),
    );
  }

  List<DashboardPage> _pagesDocente(AppUser user) => [
        _page(
          label: 'Inicio',
          icon: Icons.home_outlined,
          title: 'Inicio',
          description: 'Resumen global y por institución.',
          child: InicioCodeClassView(user: user),
        ),
        _page(
          label: 'Registro',
          icon: Icons.app_registration_outlined,
          title: 'Registro',
          description:
              'Espacio de trabajo: materias, estudiantes, equipos, clases, '
              'grupos, asistencia y actividades por institución.',
          child: const RegistroView(),
        ),
        _page(
          label: 'Teoría',
          icon: Icons.menu_book_outlined,
          title: 'Teoría',
          description: 'Contenido y materias de la institución activa.',
          child: const TeoriaView(),
        ),
        _page(
          label: 'Práctica',
          icon: Icons.code_outlined,
          title: 'Práctica',
          description: 'Plan de prácticas por institución y catálogo global.',
          child: const PracticaView(),
        ),
        _page(
          label: 'Usuario',
          icon: Icons.account_circle_outlined,
          title: 'Usuario',
          description: 'Perfil, apariencia, seguridad e información de la app.',
          child: const UsuarioView(),
        ),
        _page(
          label: 'Instituciones',
          icon: Icons.account_balance_outlined,
          title: 'Instituciones',
          description: 'Catálogo de instituciones: crea, edita o elimina.',
          child: const InstitucionesView(),
          section: DashboardSection.menu,
        ),
        _page(
          label: 'Usuarios',
          icon: Icons.manage_accounts_outlined,
          title: 'Gestión de usuarios',
          description: 'Consulta usuarios y administra sus roles.',
          child: const UsersView(),
          section: DashboardSection.menu,
          group: 'Legado',
        ),
        _page(
          label: 'Asignaciones',
          icon: Icons.link_outlined,
          title: 'Asignaciones',
          description: 'Asigna equipos del laboratorio a los estudiantes.',
          child: const AssignmentsView(),
        ),
        _page(
          label: 'Prácticas',
          icon: Icons.code,
          title: 'Prácticas de programación',
          description:
              'Registra las prácticas, lenguajes y herramientas del laboratorio.',
          child: const PracticasLegacyView(),
        ),
        _page(
          label: 'Reportes',
          icon: Icons.analytics_outlined,
          title: 'Reportes',
          description: 'Reportes de novedades del laboratorio.',
          child: const ReportesView(),
        ),
      ];

  List<DashboardPage> _pagesEstudiante(AppUser user) => [
        _page(
          label: 'Inicio',
          icon: Icons.home_outlined,
          title: 'Inicio',
          description: 'Resumen general del laboratorio.',
          child: InicioView(user: user),
        ),
        _page(
          label: 'Práctica',
          icon: Icons.code_outlined,
          title: 'Práctica',
          description: 'Plan de prácticas y catálogo global.',
          child: const PracticaView(),
        ),
        _page(
          label: 'Usuario',
          icon: Icons.account_circle_outlined,
          title: 'Usuario',
          description: 'Perfil, apariencia, seguridad e información de la app.',
          child: const UsuarioView(),
        ),
        _page(
          label: 'Mis Equipos',
          icon: Icons.devices_other_outlined,
          title: 'Mis Equipos',
          description: 'Consulta los equipos que te han sido asignados.',
          child: MyEquipmentView(user: user),
          section: DashboardSection.menu,
        ),
        _page(
          label: 'Reportes',
          icon: Icons.analytics_outlined,
          title: 'Reportes',
          description: 'Envía y consulta reportes de novedades.',
          child: const ReportesView(),
          section: DashboardSection.menu,
          group: 'Legado',
        ),
      ];

  /// Envuelve el contenido con un encabezado de página coherente.
  static DashboardPage _page({
    required String label,
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
    DashboardSection section = DashboardSection.tab,
    String? group,
  }) {
    return DashboardPage(
      label: label,
      icon: icon,
      section: section,
      group: group,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageTitle(title: title, description: description),
          const SizedBox(height: AppDimens.xl),
          child,
        ],
      ),
    );
  }
}