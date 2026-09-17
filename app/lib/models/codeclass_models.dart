/// Modelos de datos del módulo CodeClass.
library;

import '../core/constants/app_constants.dart';

/// Materia del catálogo global (CC-REG-01).
class Materia {
  const Materia({
    this.id = '',
    required this.nombre,
    this.creadoEn = '',
  });

  final String id;
  final String nombre;
  final String creadoEn;

  factory Materia.fromMap(Map<String, dynamic> data) => Materia(
        id: data['id'] as String? ?? '',
        nombre: (data['nombre'] as String? ?? '').trim(),
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {'nombre': nombre, 'creadoEn': creadoEn};
}

/// Institución con tipo y programa Pequeños Ingenieros (CC-REG-02).
class Institucion {
  const Institucion({
    this.id = '',
    required this.nombre,
    required this.tipo,
    required this.pequenosIngenieros,
    this.direccion = '',
    this.telefono = '',
    this.creadoEn = '',
  });

  final String id;
  final String nombre;
  final String tipo;
  final bool pequenosIngenieros;
  final String direccion;
  final String telefono;
  final String creadoEn;

  bool get esColegio => tipo == InstitucionTypes.colegio;
  bool get esUniversidad => tipo == InstitucionTypes.universidad;
  String get tipoLabel => InstitucionTypes.labels[tipo] ?? tipo;

  factory Institucion.fromMap(Map<String, dynamic> data) => Institucion(
        id: data['id'] as String? ?? '',
        nombre: (data['nombre'] as String? ?? '').trim(),
        tipo: data['tipo'] as String? ?? InstitucionTypes.colegio,
        pequenosIngenieros: data['pequenosIngenieros'] as bool? ?? false,
        direccion: data['direccion'] as String? ?? '',
        telefono: data['telefono'] as String? ?? '',
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'tipo': tipo,
        'pequenosIngenieros': pequenosIngenieros,
        'direccion': direccion,
        'telefono': telefono,
        'creadoEn': creadoEn,
      };
}

/// Estudiante registrado dentro de una institución (CC-REG-05).
class Estudiante {
  const Estudiante({
    this.id = '',
    required this.institucionId,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    this.edad = '',
    this.correo = '',
    this.telefono = '',
    this.numeroLista = '',
    this.creadoEn = '',
  });

  final String id;
  final String institucionId;
  final String nombre;
  final String apellido;
  final String cedula;
  final String edad;
  final String correo;
  final String telefono;
  final String numeroLista;
  final String creadoEn;

  String get nombreCompleto => '$nombre $apellido';

  /// Número de lista normalizado a dos dígitos ("01").
  String get listaFormateada {
    final n = int.tryParse(numeroLista);
    if (n == null) return numeroLista;
    return n.toString().padLeft(2, '0');
  }

  int get numeroListaOrden => int.tryParse(numeroLista) ?? 999999;

  factory Estudiante.fromMap(Map<String, dynamic> data) => Estudiante(
        id: data['id'] as String? ?? '',
        institucionId: data['institucionId'] as String? ?? '',
        nombre: (data['nombre'] as String? ?? '').trim(),
        apellido: (data['apellido'] as String? ?? '').trim(),
        cedula: (data['cedula'] as String? ?? ''),
        edad: data['edad'] is int
            ? '${data['edad']}'
            : (data['edad'] as String? ?? ''),
        correo: data['correo'] as String? ?? '',
        telefono: data['telefono'] as String? ?? '',
        numeroLista: data['numeroLista'] is int
            ? '${data['numeroLista']}'
            : (data['numeroLista'] as String? ?? ''),
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'institucionId': institucionId,
        'nombre': nombre,
        'apellido': apellido,
        'cedula': cedula,
        'edad': edad,
        'correo': correo,
        'telefono': telefono,
        'numeroLista': numeroLista,
        'creadoEn': creadoEn,
      };
}

/// Clase registrada dentro de una institución (CC-REG-06).
class Clase {
  const Clase({
    this.id = '',
    required this.institucionId,
    this.materiaId = '',
    this.materia = '',
    required this.tipoInst,
    this.anio = '',
    this.grado = '',
    this.seccion = '',
    this.carrera = '',
    this.semestre = '',
    this.fecha = '',
    this.creadoEn = '',
  });

  final String id;
  final String institucionId;
  final String materiaId;
  final String materia;
  final String tipoInst;
  final String anio;
  final String grado;
  final String seccion;
  final String carrera;
  final String semestre;
  final String fecha;
  final String creadoEn;

  bool get esColegio => tipoInst == InstitucionTypes.colegio;

  /// Nombre legible de la clase: "2do C — ITP" o "Ing. Sistemas · Prog. II".
  String get nombreMuestra {
    if (esColegio) {
      final base = [anio, grado, seccion].where((x) => x.trim().isNotEmpty).join(' ');
      return base.isEmpty ? materia : '$base — $materia';
    }
    final base = [carrera, semestre].where((x) => x.trim().isNotEmpty).join(' · ');
    return base.isEmpty ? materia : '$base · $materia';
  }

  factory Clase.fromMap(Map<String, dynamic> data) => Clase(
        id: data['id'] as String? ?? '',
        institucionId: data['institucionId'] as String? ?? '',
        materiaId: data['materiaId'] as String? ?? '',
        materia: data['materia'] as String? ?? '',
        tipoInst: data['tipoInst'] as String? ?? InstitucionTypes.colegio,
        anio: data['anio'] as String? ?? '',
        grado: data['grado'] as String? ?? '',
        seccion: data['seccion'] as String? ?? '',
        carrera: data['carrera'] as String? ?? '',
        semestre: data['semestre'] as String? ?? '',
        fecha: data['fecha'] as String? ?? '',
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'institucionId': institucionId,
        'materiaId': materiaId,
        'materia': materia,
        'tipoInst': tipoInst,
        'anio': anio,
        'grado': grado,
        'seccion': seccion,
        'carrera': carrera,
        'semestre': semestre,
        'fecha': fecha,
        'creadoEn': creadoEn,
      };
}

/// Equipo con componentes Tiene/No tiene y serial (CC-REG-04).
class Equipo {
  const Equipo({
    this.id = '',
    required this.institucionId,
    this.codigo = '',
    this.componentes = const {},
    this.creadoEn = '',
  });

  final String id;
  final String institucionId;
  final String codigo;
  final Map<String, Map<String, dynamic>> componentes;
  final String creadoEn;

  bool tiene(String componente) {
    final c = componentes[componente];
    return c != null && (c['tiene'] as bool? ?? false);
  }

  String serialDe(String componente) {
    final c = componentes[componente];
    return c?['serial'] as String? ?? '';
  }

  factory Equipo.fromMap(Map<String, dynamic> data) => Equipo(
        id: data['id'] as String? ?? '',
        institucionId: data['institucionId'] as String? ?? '',
        codigo: data['codigo'] as String? ?? '',
        componentes: (data['componentes'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(
                k, Map<String, dynamic>.from(v as Map<String, dynamic>))),
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'institucionId': institucionId,
        'codigo': codigo,
        'componentes': componentes,
        'creadoEn': creadoEn,
      };
}

/// Membresía de un estudiante en una clase.
class ClaseEstudiante {
  const ClaseEstudiante({
    this.id = '',
    required this.claseId,
    required this.estudianteId,
    this.grupo = '',
  });

  final String id;
  final String claseId;
  final String estudianteId;
  final String grupo;

  factory ClaseEstudiante.fromMap(Map<String, dynamic> data) => ClaseEstudiante(
        id: data['id'] as String? ?? '',
        claseId: data['claseId'] as String? ?? '',
        estudianteId: data['estudianteId'] as String? ?? '',
        grupo: data['grupo'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'claseId': claseId,
        'estudianteId': estudianteId,
        'grupo': grupo,
      };
}

/// Registro de asistencia (CC-REG-08 / CC-REG-09).
class Asistencia {
  const Asistencia({
    this.id = '',
    required this.claseId,
    required this.institucionId,
    this.fecha = '',
    this.modalidad = '',
    this.grupo = '',
    this.estudiantes = const {},
    this.creadoEn = '',
  });

  final String id;
  final String claseId;
  final String institucionId;
  final String fecha;
  final String modalidad;
  final String grupo;
  final Map<String, bool> estudiantes;
  final String creadoEn;

  factory Asistencia.fromMap(Map<String, dynamic> data) => Asistencia(
        id: data['id'] as String? ?? '',
        claseId: data['claseId'] as String? ?? '',
        institucionId: data['institucionId'] as String? ?? '',
        fecha: data['fecha'] as String? ?? '',
        modalidad: data['modalidad'] as String? ?? '',
        grupo: data['grupo'] as String? ?? '',
        estudiantes: Map<String, bool>.from(data['estudiantes'] as Map? ?? {}),
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'claseId': claseId,
        'institucionId': institucionId,
        'fecha': fecha,
        'modalidad': modalidad,
        'grupo': grupo,
        'estudiantes': estudiantes,
        'creadoEn': creadoEn,
      };
}

/// Actividad registrada sobre una clase (CC-REG-10).
class Actividad {
  const Actividad({
    this.id = '',
    required this.claseId,
    required this.institucionId,
    this.materia = '',
    this.modalidad = '',
    this.tema = '',
    this.fecha = '',
    this.contenido = '',
    this.grupo = '',
    this.creadoEn = '',
  });

  final String id;
  final String claseId;
  final String institucionId;
  final String materia;
  final String modalidad;
  final String tema;
  final String fecha;
  final String contenido;
  final String grupo;
  final String creadoEn;

  factory Actividad.fromMap(Map<String, dynamic> data) => Actividad(
        id: data['id'] as String? ?? '',
        claseId: data['claseId'] as String? ?? '',
        institucionId: data['institucionId'] as String? ?? '',
        materia: data['materia'] as String? ?? '',
        modalidad: data['modalidad'] as String? ?? '',
        tema: data['tema'] as String? ?? '',
        fecha: data['fecha'] as String? ?? '',
        contenido: data['contenido'] as String? ?? '',
        grupo: data['grupo'] as String? ?? '',
        creadoEn: data['creadoEn'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'claseId': claseId,
        'institucionId': institucionId,
        'materia': materia,
        'modalidad': modalidad,
        'tema': tema,
        'fecha': fecha,
        'contenido': contenido,
        'grupo': grupo,
        'creadoEn': creadoEn,
      };
}