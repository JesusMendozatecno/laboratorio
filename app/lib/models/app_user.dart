/// Usuario de la aplicación, almacenado en Firestore (`usuarios`).
class AppUser {
  const AppUser({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.correo,
    required this.tipo,
  });

  final String uid;
  final String nombre;
  final String apellido;
  final String cedula;
  final String correo;
  final String tipo;

  String get nombreCompleto => '$nombre $apellido';

  bool get esDocente => tipo == 'docente';
  bool get esEncargado => tipo == 'encargado';
  bool get esEstudiante => tipo == 'estudiante';

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'correo': correo,
      'tipo': tipo,
    };
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] as String? ?? '',
      nombre: data['nombre'] as String? ?? '',
      apellido: data['apellido'] as String? ?? '',
      cedula: data['cedula'] as String? ?? '',
      correo: data['correo'] as String? ?? '',
      tipo: data['tipo'] as String? ?? 'estudiante',
    );
  }
}