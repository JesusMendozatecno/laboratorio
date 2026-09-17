/// Identificador de la colección de usuarios en Firestore.
const String kUsuariosCollection = 'usuarios';

/// Colección de clases registradas.
const String kClasesCollection = 'clases';

/// Colección de reportes de problemas.
const String kReportesCollection = 'reportes';

/// Colección de equipos del laboratorio.
const String kEquiposCollection = 'equipos';

/// Colección de institutos.
const String kInstitutosCollection = 'institutos';

/// Colección de profesores.
const String kProfesoresCollection = 'profesores';

/// Colección de asignaciones de estudiantes a equipos.
const String kAsignacionesCollection = 'asignaciones';

/// Colección de prácticas de programación.
const String kPracticasCollection = 'practicas';

/// Roles de usuario del sistema.
class UserRoles {
  UserRoles._();

  static const String estudiante = 'estudiante';
  static const String docente = 'docente';
  static const String encargado = 'encargado';

  static const Map<String, String> labels = {
    estudiante: 'Estudiante',
    docente: 'Docente',
    encargado: 'Encargado',
  };
}

/// Textos reutilizables.
class AppStrings {
  AppStrings._();

  static const String appName = 'Laboratorio de Programación';
  static const String tagline = 'Sistema de gestión de clases, equipos y prácticas';
  static const String loginTitle = 'Iniciar Sesión';
  static const String registerTitle = 'Registro';
  static const String welcomeHome = 'Seleccione una opción del menú';

  /// Nombre completo del laboratorio mostrado en las normas.
  static const String labName = 'Laboratorio de Programación';

  /// Institución a la que pertenece el laboratorio.
  static const String institution = 'U.E. Colegio Los Ángeles';

  /// Responsable del laboratorio.
  static const String labTeacher = 'Prof. Ylse Ceromoto Ojeda De Hernández';
}