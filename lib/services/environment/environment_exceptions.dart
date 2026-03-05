import 'dart:io';

import 'package:dio/dio.dart';

/// Base exception thrown when fetching remote environment data fails.
///
/// This is intended to be safe to log: the [endpoint] value is redacted to
/// remove query parameters (which may include secrets or user-specific data).
sealed class EnvironmentFetchException implements Exception {
  const EnvironmentFetchException({
    required this.provider,
    required this.message,
    this.endpoint,
    this.statusCode,
    this.cause,
  });

  final String provider;
  final String message;
  final Uri? endpoint;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (status: $statusCode)';
    final uri = endpoint == null ? '' : ' [$endpoint]';
    return '$provider: $message$status$uri';
  }
}

class EnvironmentOfflineException extends EnvironmentFetchException {
  const EnvironmentOfflineException({
    required super.provider,
    required super.message,
    super.endpoint,
    super.cause,
  });
}

class EnvironmentTimeoutException extends EnvironmentFetchException {
  const EnvironmentTimeoutException({
    required super.provider,
    required super.message,
    super.endpoint,
    super.cause,
  });
}

/// Non-2xx HTTP response from the environment provider.
class EnvironmentHttpException extends EnvironmentFetchException {
  const EnvironmentHttpException({
    required super.provider,
    required super.message,
    required int statusCode,
    super.endpoint,
    super.cause,
  }) : super(statusCode: statusCode);

  @override
  int get statusCode => super.statusCode!;

  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500 && statusCode < 600;
}

class EnvironmentClientErrorException extends EnvironmentHttpException {
  const EnvironmentClientErrorException({
    required super.provider,
    required super.message,
    required super.statusCode,
    super.endpoint,
    super.cause,
  });
}

class EnvironmentServerErrorException extends EnvironmentHttpException {
  const EnvironmentServerErrorException({
    required super.provider,
    required super.message,
    required super.statusCode,
    super.endpoint,
    super.cause,
  });
}

class EnvironmentRequestCancelledException extends EnvironmentFetchException {
  const EnvironmentRequestCancelledException({
    required super.provider,
    required super.message,
    super.endpoint,
    super.cause,
  });
}

class EnvironmentUnknownException extends EnvironmentFetchException {
  const EnvironmentUnknownException({
    required super.provider,
    required super.message,
    super.endpoint,
    super.cause,
  });
}

EnvironmentFetchException environmentFetchExceptionFromDio(
  DioException exception, {
  required String provider,
}) {
  final endpoint = _redactEndpoint(exception.requestOptions.uri);
  final statusCode = exception.response?.statusCode;
  final safeCause = exception.error ?? exception.type;

  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return EnvironmentTimeoutException(
        provider: provider,
        message: 'Request timed out',
        endpoint: endpoint,
        cause: safeCause,
      );
    case DioExceptionType.badResponse:
      if (statusCode != null && statusCode >= 500) {
        return EnvironmentServerErrorException(
          provider: provider,
          message: 'Server error',
          statusCode: statusCode,
          endpoint: endpoint,
          cause: safeCause,
        );
      }
      if (statusCode != null && statusCode >= 400) {
        return EnvironmentClientErrorException(
          provider: provider,
          message: 'Request failed',
          statusCode: statusCode,
          endpoint: endpoint,
          cause: safeCause,
        );
      }
      return EnvironmentHttpException(
        provider: provider,
        message: 'HTTP error',
        statusCode: statusCode ?? -1,
        endpoint: endpoint,
        cause: safeCause,
      );
    case DioExceptionType.connectionError:
      return EnvironmentOfflineException(
        provider: provider,
        message: 'No network connection',
        endpoint: endpoint,
        cause: safeCause,
      );
    case DioExceptionType.cancel:
      return EnvironmentRequestCancelledException(
        provider: provider,
        message: 'Request cancelled',
        endpoint: endpoint,
        cause: safeCause,
      );
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      // Fall through to more specific detection below.
      break;
  }

  final error = exception.error;
  if (error is SocketException) {
    return EnvironmentOfflineException(
      provider: provider,
      message: 'No network connection',
      endpoint: endpoint,
      cause: safeCause,
    );
  }

  return EnvironmentUnknownException(
    provider: provider,
    message: exception.message ?? 'Unexpected network error',
    endpoint: endpoint,
    cause: safeCause,
  );
}

Uri _redactEndpoint(Uri uri) {
  return Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo.isEmpty ? null : uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  );
}
