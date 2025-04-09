class DuplicateException implements Exception {
  final String message;

  DuplicateException([this.message = "Entrada duplicada encontrada."]);

  @override
  String toString() => message;
}
