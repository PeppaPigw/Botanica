abstract class AiException implements Exception {
  const AiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'AiException(statusCode: $statusCode, message: $message)';
}

class AiNotConfiguredException extends AiException {
  const AiNotConfiguredException(super.message);
}

class AiUnauthorizedException extends AiException {
  const AiUnauthorizedException(super.message, {super.statusCode});
}

class AiRateLimitException extends AiException {
  const AiRateLimitException(
    super.message, {
    super.statusCode,
    this.retryAfterSeconds,
  });

  final int? retryAfterSeconds;
}

class AiUnavailableException extends AiException {
  const AiUnavailableException(super.message, {super.statusCode});
}

class AiRequestException extends AiException {
  const AiRequestException(super.message, {super.statusCode});
}
