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

/// Colección de materias (catálogo reutilizable).
const String kMateriasCollection = 'materias';

/// Colección de instituciones (espacio de trabajo independiente).
const String kInstitucionesCollection = 'instituciones';

/// Colección de estudiantes por institución.
const String kEstudiantesCollection = 'estudiantes';

/// Colección de membresías estudiante↔clase (con grupo asignado).
const String kClaseEstudiantesCollection = 'clase_estudiantes';

/// Colección de asistencias.
const String kAsistenciasCollection = 'asistencias';

/// Colección de actividades por clase.
const String kActividadesCollection = 'actividades';

/// Tipos de institución.
class InstitucionTypes {
  InstitucionTypes._();

  static const String colegio = 'colegio';
  static const String universidad = 'universidad';

  static const Map<String, String> labels = {
    colegio: 'Colegio',
    universidad: 'Universidad',
  };
}

/// Modalidades de clase/asistencia/actividad.
class Modalidades {
  Modalidades._();

  static const String teoria = 'Teoría';
  static const String laboratorio = 'Laboratorio';
  static const String practica = 'Práctica';

  static const List<String> teoriaLaboratorio = [teoria, laboratorio];
  static const List<String> teoriaPractica = [teoria, practica];
}

/// Grupos de laboratorio.
class Grupos {
  Grupos._();

  static const String grupo1 = '1';
  static const String grupo2 = '2';

  static const List<String> opciones = [grupo1, grupo2];

  static String label(String? grupo) {
    return grupo == null ? 'Sin grupo' : 'Grupo $grupo';
  }
}

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

  static const String appName = 'CodeClass';
  static const String tagline = 'Gestión de clases de programación';
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