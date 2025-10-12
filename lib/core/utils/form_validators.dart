class FormValidators {
  /// Validador para campos de texto que não podem estar vazios.
  static String? notEmpty(String? value, {String fieldName = 'campo'}) {
    if (value == null || value.trim().isEmpty) {
      return 'O $fieldName não pode estar vazio.';
    }
    return null;
  }

  /// Validador para o campo de e-mail.
  static String? email(String? value) {
    final notEmptyValidation = notEmpty(value, fieldName: 'e-mail');
    if (notEmptyValidation != null) {
      return notEmptyValidation;
    }
    // Expressão regular para validar o formato do e-mail
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  /// Validador para o campo de senha.
  static String? password(String? value) {
    final notEmptyValidation = notEmpty(value, fieldName: 'senha');
    if (notEmptyValidation != null) {
      return notEmptyValidation;
    }
    if (value!.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  /// Validador para o campo de confirmação de senha.
  static String? confirmPassword(String? value, String password) {
    final notEmptyValidation = notEmpty(
      value,
      fieldName: 'confirmação de senha',
    );
    if (notEmptyValidation != null) {
      return notEmptyValidation;
    }
    if (value != password) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Validador para campos de seleção (Dropdown).
  static String? selection<T>(T? value, {String fieldName = 'campo'}) {
    if (value == null) {
      return 'Por favor, selecione um(a) $fieldName.';
    }
    return null;
  }
}
