/// Validadores de formularios.
class Validators {
  Validators._();

  static String? required(String? value, [String message = 'Campo requerido']) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? message : null;
  }

  static String? cedula(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingrese su cédula';
    if (!RegExp(r'^\d{6,9}$').hasMatch(v)) {
      return 'Cédula inválida (solo números, 6-9 dígitos)';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingrese su correo';
    if (!RegExp(r'^[\w\.\-]+@[\w\-\.]+\.\w{2,}$').hasMatch(v)) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? password(String? value, [String message = 'Contraseña inválida']) {
    final v = value ?? '';
    if (v.isEmpty) return 'Ingrese su contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirme su contraseña';
    if (v != original) return 'Las contraseñas no coinciden';
    return null;
  }
}