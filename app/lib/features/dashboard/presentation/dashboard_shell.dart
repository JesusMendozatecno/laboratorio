import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/page_title.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/app_user.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/assignments_view.dart';
import '../widgets/collection_list.dart';
import '../widgets/entity_form.dart';
import '../widgets/form_specs.dart';
import '../widgets/inicio_view.dart';
import '../widgets/my_equipment_view.dart';
import '../widgets/settings_view.dart';
import '../widgets/students_view.dart';
import '../widgets/users_view.dart';
import 'dashboard_layout.dart';

/// Panel principal que arma las secciones según el rol del usuario.
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
      pages: _pagesFor(user.tipo, user),
    );
  }

  List<DashboardPage> _pagesFor(String tipo, AppUser user) {
    final pages = switch (tipo) {
      UserRoles.encargado => <DashboardPage>[
          _page(
            label: 'Inicio',
            icon: Icons.home_outlined,
            title: 'Inicio',
            description: 'Resumen general de la actividad del laboratorio.',
            child: InicioView(user: user),
          ),
          _page(
            label: 'Profesores',
            icon: Icons.school_outlined,
            title: 'Profesores',
            description: 'Registro de profesores que imparten clases.',
            child: _FormAndList(
              form: EntityForm(
                collection: kProfesoresCollection,
                fields: FormSpecs.profesor,
                submitLabel: 'Registrar Profesor',
              ),
              list: CollectionList(
                collection: kProfesoresCollection,
                title: 'Profesores registrados',
                columns: const [
                  ListColumn('nombre', 'Nombre'),
                  ListColumn('apellido', 'Apellido'),
                  ListColumn('cedula', 'Cédula'),
                  ListColumn('materia', 'Materia'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Institutos',
            icon: Icons.account_balance_outlined,
            title: 'Institutos',
            description: 'Institutos asociados al laboratorio.',
            child: _FormAndList(
              form: EntityForm(
                collection: kInstitutosCollection,
                fields: FormSpecs.instituto,
                submitLabel: 'Registrar Instituto',
              ),
              list: CollectionList(
                collection: kInstitutosCollection,
                title: 'Institutos registrados',
                columns: const [
                  ListColumn('nombre', 'Nombre'),
                  ListColumn('direccion', 'Dirección'),
                  ListColumn('telefono', 'Teléfono'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Clases',
            icon: Icons.class_outlined,
            title: 'Clases',
            description: 'Administración de las clases del laboratorio.',
            child: _FormAndList(
              form: EntityForm(
                collection: kClasesCollection,
                fields: FormSpecs.clase,
                submitLabel: 'Registrar Clase',
              ),
              list: CollectionList(
                collection: kClasesCollection,
                title: 'Clases registradas',
                columns: const [
                  ListColumn('materia', 'Materia'),
                  ListColumn('profesor', 'Profesor'),
                  ListColumn('fecha', 'Fecha'),
                  ListColumn('tipo_clase', 'Tipo'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Equipos',
            icon: Icons.devices_outlined,
            title: 'Equipos',
            description: 'Inventario de los equipos del laboratorio.',
            child: _FormAndList(
              form: EntityForm(
                collection: kEquiposCollection,
                fields: FormSpecs.equipo,
                submitLabel: 'Registrar Equipo',
              ),
              list: CollectionList(
                collection: kEquiposCollection,
                title: 'Equipos registrados',
                columns: const [
                  ListColumn('codigo', 'Código'),
                  ListColumn('tipo', 'Tipo'),
                  ListColumn('marca', 'Marca'),
                  ListColumn('estado', 'Estado'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Estudiantes',
            icon: Icons.groups_outlined,
            title: 'Estudiantes',
            description: 'Registra estudiantes y consulta los existentes.',
            child: const StudentsView(),
          ),
          _page(
            label: 'Asignaciones',
            icon: Icons.link_outlined,
            title: 'Asignaciones',
            description:
                'Asigna equipos del laboratorio a los estudiantes registrados.',
            child: const AssignmentsView(),
          ),
          _page(
            label: 'Usuarios',
            icon: Icons.manage_accounts_outlined,
            title: 'Gestión de usuarios',
            description: 'Consulta usuarios y administra sus roles.',
            child: const UsersView(),
          ),
          _page(
            label: 'Prácticas',
            icon: Icons.code,
            title: 'Prácticas de programación',
            description:
                'Registra las prácticas, lenguajes y herramientas del laboratorio.',
            child: _FormAndList(
              form: EntityForm(
                collection: kPracticasCollection,
                fields: FormSpecs.practica,
                submitLabel: 'Registrar Práctica',
              ),
              list: CollectionList(
                collection: kPracticasCollection,
                title: 'Prácticas registradas',
                columns: const [
                  ListColumn('titulo', 'Título'),
                  ListColumn('materia', 'Materia'),
                  ListColumn('lenguaje', 'Lenguaje'),
                  ListColumn('dificultad', 'Dificultad'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Reportes',
            icon: Icons.analytics_outlined,
            title: 'Reportes',
            description: 'Reportes de novedades del laboratorio.',
            child: _FormAndList(
              form: EntityForm(
                collection: kReportesCollection,
                fields: FormSpecs.reporte,
                submitLabel: 'Crear Reporte',
              ),
              list: CollectionList(
                collection: kReportesCollection,
                title: 'Reportes registrados',
                columns: const [
                  ListColumn('descripcion', 'Descripción'),
                  ListColumn('creadoEn', 'Fecha'),
                ],
              ),
            ),
          ),
        ],
      UserRoles.estudiante => <DashboardPage>[
          _page(
            label: 'Inicio',
            icon: Icons.home_outlined,
            title: 'Inicio',
            description: 'Resumen general del laboratorio.',
            child: InicioView(user: user),
          ),
          _page(
            label: 'Clases',
            icon: Icons.class_outlined,
            title: 'Clases',
            description: 'Clases disponibles en el laboratorio.',
            child: CollectionList(
              collection: kClasesCollection,
              title: 'Clases disponibles',
              columns: const [
                ListColumn('materia', 'Materia'),
                ListColumn('profesor', 'Profesor'),
                ListColumn('fecha', 'Fecha'),
                ListColumn('hora_entrada', 'Entrada'),
              ],
            ),
          ),
          _page(
            label: 'Mis Equipos',
            icon: Icons.devices_other_outlined,
            title: 'Mis Equipos',
            description: 'Consulta los equipos que te han sido asignados.',
            child: MyEquipmentView(user: user),
          ),
          _page(
            label: 'Prácticas',
            icon: Icons.code,
            title: 'Prácticas de programación',
            description: 'Consulta las prácticas, lenguajes y herramientas.',
            child: CollectionList(
              collection: kPracticasCollection,
              title: 'Prácticas disponibles',
              columns: const [
                ListColumn('titulo', 'Título'),
                ListColumn('materia', 'Materia'),
                ListColumn('lenguaje', 'Lenguaje'),
                ListColumn('herramienta', 'Software'),
              ],
            ),
          ),
          _page(
            label: 'Reportes',
            icon: Icons.analytics_outlined,
            title: 'Reportes',
            description: 'Envía y consulta reportes de novedades.',
            child: _FormAndList(
              form: EntityForm(
                collection: kReportesCollection,
                fields: FormSpecs.reporte,
                submitLabel: 'Enviar Reporte',
              ),
              list: CollectionList(
                collection: kReportesCollection,
                title: 'Reportes enviados',
                columns: const [
                  ListColumn('descripcion', 'Descripción'),
                  ListColumn('creadoEn', 'Fecha'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Perfil',
            icon: Icons.account_circle_outlined,
            title: 'Mi Perfil',
            description: 'Información de tu cuenta.',
            child: _PerfilView(user: user),
          ),
        ],
      UserRoles.docente || _ => <DashboardPage>[
          _page(
            label: 'Inicio',
            icon: Icons.home_outlined,
            title: 'Inicio',
            description: 'Resumen general del laboratorio.',
            child: InicioView(user: user),
          ),
          _page(
            label: 'Registrar Clase',
            icon: Icons.edit_calendar_outlined,
            title: 'Registrar Clase',
            description: 'Registra una nueva clase en el laboratorio.',
            child: EntityForm(
              collection: kClasesCollection,
              fields: FormSpecs.clase,
              submitLabel: 'Registrar Clase',
            ),
          ),
          _page(
            label: 'Ver Clases',
            icon: Icons.list_alt_outlined,
            title: 'Clases registradas',
            description: 'Listado de las clases ya registradas.',
            child: CollectionList(
              collection: kClasesCollection,
              title: 'Clases registradas',
              columns: const [
                ListColumn('materia', 'Materia'),
                ListColumn('profesor', 'Profesor'),
                ListColumn('fecha', 'Fecha'),
                ListColumn('tipo_clase', 'Tipo'),
              ],
            ),
          ),
          _page(
            label: 'Prácticas',
            icon: Icons.code,
            title: 'Prácticas de programación',
            description:
                'Registra las prácticas, lenguajes y herramientas usadas en clase.',
            child: _FormAndList(
              form: EntityForm(
                collection: kPracticasCollection,
                fields: FormSpecs.practica,
                submitLabel: 'Registrar Práctica',
              ),
              list: CollectionList(
                collection: kPracticasCollection,
                title: 'Prácticas registradas',
                columns: const [
                  ListColumn('titulo', 'Título'),
                  ListColumn('materia', 'Materia'),
                  ListColumn('lenguaje', 'Lenguaje'),
                  ListColumn('dificultad', 'Dificultad'),
                ],
              ),
            ),
          ),
          _page(
            label: 'Reportes',
            icon: Icons.analytics_outlined,
            title: 'Reportes',
            description: 'Reportes de novedades del laboratorio.',
            child: _FormAndList(
              form: EntityForm(
                collection: kReportesCollection,
                fields: FormSpecs.reporte,
                submitLabel: 'Crear Reporte',
              ),
              list: CollectionList(
                collection: kReportesCollection,
                title: 'Reportes',
                columns: const [
                  ListColumn('descripcion', 'Descripción'),
                  ListColumn('creadoEn', 'Fecha'),
                ],
              ),
            ),
          ),
        ],
    };

    pages.add(_page(
      label: 'Configuración',
      icon: Icons.palette_outlined,
      title: 'Configuración',
      description: 'Tu cuenta, la apariencia y la información de la aplicación.',
      child: const SettingsView(),
    ));
    return pages;
  }

  /// Envuelve el contenido con un encabezado de página coherente.
  static DashboardPage _page({
    required String label,
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    return DashboardPage(
      label: label,
      icon: icon,
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

/// Combina un formulario y su listado en una columna.
class _FormAndList extends StatelessWidget {
  const _FormAndList({required this.form, required this.list});

  final Widget form;
  final Widget list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        form,
        const SizedBox(height: AppDimens.xl),
        list,
      ],
    );
  }
}

class _PerfilView extends StatelessWidget {
  const _PerfilView({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Mis datos',
      icon: Icons.account_circle_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(context, 'Nombre', '${user.nombre} ${user.apellido}'),
          _row(context, 'Cédula', user.cedula),
          _row(context, 'Correo', user.correo),
          _row(context, 'Rol', UserRoles.labels[user.tipo] ?? user.tipo),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}