class Failure implements Exception {
  final String message;
  final String? code;
  final dynamic exception;

  const Failure(this.message, {this.code, this.exception});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
