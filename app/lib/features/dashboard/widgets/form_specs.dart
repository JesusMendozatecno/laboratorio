import 'package:flutter/material.dart';

import 'entity_form.dart';

/// Conjuntos de campos reutilizados por los formularios de las colecciones.
class FormSpecs {
  FormSpecs._();

  static const List<FieldSpec> clase = [
    FieldSpec(key: 'materia', label: 'Materia', icon: Icons.menu_book),
    FieldSpec(key: 'profesor', label: 'Profesor', icon: Icons.person),
    FieldSpec(key: 'carrera', label: 'Carrera', icon: Icons.school),
    FieldSpec(key: 'seccion', label: 'Sección', icon: Icons.groups),
    FieldSpec(
      key: 'tipo_clase',
      label: 'Tipo de Clase',
      type: FieldType.dropdown,
      options: ['Teórica', 'Práctica'],
      icon: Icons.category,
    ),
    FieldSpec(
      key: 'cantidad',
      label: 'Cantidad de Alumnos',
      type: FieldType.number,
      icon: Icons.numbers,
    ),
    FieldSpec(
      key: 'hora_entrada',
      label: 'Hora Entrada',
      hint: 'Ej: 8:00 AM',
      icon: Icons.login,
    ),
    FieldSpec(
      key: 'hora_salida',
      label: 'Hora Salida',
      hint: 'Ej: 11:00 AM',
      icon: Icons.logout,
    ),
    FieldSpec(
      key: 'fecha',
      label: 'Fecha',
      hint: 'Ej: 2026-09-16',
      icon: Icons.calendar_today,
    ),
  ];

  static const List<FieldSpec> reporte = [
    FieldSpec(
      key: 'descripcion',
      label: 'Descripción',
      type: FieldType.multiline,
      hint: 'Describe el problema encontrado',
      icon: Icons.description_outlined,
    ),
  ];

  static const List<FieldSpec> profesor = [
    FieldSpec(key: 'nombre', label: 'Nombre', icon: Icons.person),
    FieldSpec(key: 'apellido', label: 'Apellido', icon: Icons.person_outline),
    FieldSpec(key: 'cedula', label: 'Cédula', icon: Icons.credit_card),
    FieldSpec(
      key: 'correo',
      label: 'Correo',
      icon: Icons.email,
      required: false,
    ),
    FieldSpec(
      key: 'materia',
      label: 'Materia',
      icon: Icons.menu_book,
      required: false,
    ),
  ];

  static const List<FieldSpec> instituto = [
    FieldSpec(key: 'nombre', label: 'Nombre', icon: Icons.apartment),
    FieldSpec(key: 'direccion', label: 'Dirección', icon: Icons.place),
    FieldSpec(
      key: 'telefono',
      label: 'Teléfono',
      icon: Icons.phone,
      required: false,
    ),
  ];

  static const List<FieldSpec> equipo = [
    FieldSpec(key: 'codigo', label: 'Código', icon: Icons.qr_code),
    FieldSpec(key: 'tipo', label: 'Tipo', icon: Icons.devices),
    FieldSpec(key: 'marca', label: 'Marca', icon: Icons.branding_watermark),
    FieldSpec(
      key: 'modelo',
      label: 'Modelo',
      icon: Icons.memory,
      required: false,
    ),
    FieldSpec(
      key: 'estado',
      label: 'Estado',
      type: FieldType.dropdown,
      options: ['Operativo', 'En mantenimiento', 'Fuera de servicio'],
      icon: Icons.health_and_safety,
    ),
  ];

  /// Prácticas de programación: ejercicios, lenguajes y herramientas usadas.
  static const List<FieldSpec> practica = [
    FieldSpec(
      key: 'titulo',
      label: 'Título de la práctica',
      hint: 'Ej: Introducción a funciones',
      icon: Icons.code,
    ),
    FieldSpec(key: 'materia', label: 'Materia', icon: Icons.menu_book),
    FieldSpec(
      key: 'lenguaje',
      label: 'Lenguaje',
      type: FieldType.dropdown,
      options: ['Python', 'Java', 'JavaScript', 'C++', 'C#', 'PHP', 'Dart', 'Otro'],
      icon: Icons.terminal,
    ),
    FieldSpec(
      key: 'herramienta',
      label: 'Software / IDE',
      hint: 'Ej: VS Code, NetBeans, PyCharm',
      icon: Icons.desktop_windows,
      required: false,
    ),
    FieldSpec(
      key: 'dificultad',
      label: 'Dificultad',
      type: FieldType.dropdown,
      options: ['Básica', 'Intermedia', 'Avanzada'],
      icon: Icons.speed,
    ),
    FieldSpec(
      key: 'descripcion',
      label: 'Descripción',
      type: FieldType.multiline,
      hint: 'Objetivo y contenido de la práctica',
      icon: Icons.notes,
      required: false,
    ),
    FieldSpec(
      key: 'fecha',
      label: 'Fecha',
      hint: 'Ej: 2026-09-16',
      icon: Icons.calendar_today_outlined,
      required: false,
    ),
  ];
}