class ApiException implements Exception {
  final String errorCode;
  final String errorMessage;

  ApiException(this.errorCode, this.errorMessage);

  @override
  String toString() => errorMessage;
}