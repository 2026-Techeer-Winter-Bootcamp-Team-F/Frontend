class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = '인증이 필요합니다'})
      : super(statusCode: 401, message: message);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = '요청한 리소스를 찾을 수 없습니다'})
      : super(statusCode: 404, message: message);
}
