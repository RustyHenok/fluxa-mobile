class FluxaException implements Exception {
  const FluxaException({
    required this.message,
    this.code = 'internal_error',
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'FluxaException($statusCode, $code, $message)';
}
