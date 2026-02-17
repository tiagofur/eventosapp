class Validators {
  static String? email(String? value) {
    if (value == null || value!.isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value!.isEmpty) {
      return 'El teléfono es requerido';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,14}$');
    if (!phoneRegex.hasMatch(value!)) {
      return 'Teléfono inválido';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value!.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, String fieldName) {
    if (value != null && value!.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value!.length > maxLength) {
      return '$fieldName no debe exceder $maxLength caracteres';
    }
    return null;
  }

  static String? positiveNumber(String? value, String fieldName) {
    if (value != null && double.tryParse(value!) == null || double.parse(value!)! <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    return null;
  }
}
