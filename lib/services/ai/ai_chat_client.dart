import 'dart:io';

import 'package:dio/dio.dart';

import 'ai_config.dart';
import 'ai_exceptions.dart';

class AiChatClient {
  AiChatClient({
    required AiConfig config,
    String? apiKey,
    Dio? dio,
  })  : _config = config,
        _apiKey = apiKey?.trim(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _normalizeBaseUrl(config.baseUrl),
                connectTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
                responseType: ResponseType.json,
                headers: <String, dynamic>{
                  HttpHeaders.contentTypeHeader: 'application/json',
                  if (config.proxyToken.trim().isNotEmpty)
                    'X-Botanica-Client': config.proxyToken.trim(),
                },
              ),
            );

  final AiConfig _config;
  final String? _apiKey;
  final Dio _dio;

  bool get isConfigured {
    final base = _config.baseUrl.trim();
    if (base.isEmpty) return false;
    return !_config.requiresApiKey ||
        (_apiKey != null && _apiKey.trim().isNotEmpty);
  }

  Future<String> createChatCompletion({
    required List<Map<String, String>> messages,
    double temperature = 0.35,
    int maxTokens = 220,
  }) async {
    if (_config.baseUrl.trim().isEmpty) {
      throw const AiNotConfiguredException(
        'AI is not configured (missing base URL).',
      );
    }
    if (_config.requiresApiKey && !isConfigured) {
      throw const AiNotConfiguredException(
        'AI is not configured (missing API key).',
      );
    }

    try {
      final authHeader = _config.requiresApiKey
          ? <String, dynamic>{
              HttpHeaders.authorizationHeader: 'Bearer ${_apiKey!}',
            }
          : const <String, dynamic>{};

      final response = await _dio.post<Map<String, dynamic>>(
        _chatCompletionsPath(_dio.options.baseUrl),
        data: <String, dynamic>{
          'model': _config.model,
          'messages': messages,
          'stream': false,
          'temperature': temperature,
          'max_tokens': maxTokens,
        },
        options: Options(headers: authHeader),
      );

      final data = response.data;
      if (data == null) {
        throw const AiRequestException('AI response was empty');
      }

      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const AiRequestException('AI response missing choices');
      }

      final first = choices.first;
      if (first is! Map) {
        throw const AiRequestException('AI choice was invalid');
      }

      final message = first['message'];
      if (message is! Map) {
        throw const AiRequestException('AI response missing message');
      }

      final content = message['content']?.toString();
      if (content == null || content.trim().isEmpty) {
        throw const AiRequestException('AI response content was empty');
      }

      return content.trim();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }
}

AiException _mapDioException(DioException e) {
  final statusCode = e.response?.statusCode;
  final retryAfter = int.tryParse(
    e.response?.headers.value(HttpHeaders.retryAfterHeader) ?? '',
  );

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return AiUnavailableException(
        'AI request timed out.',
        statusCode: statusCode,
      );
    case DioExceptionType.connectionError:
      return AiUnavailableException(
        'AI network error.',
        statusCode: statusCode,
      );
    case DioExceptionType.badResponse:
      if (statusCode == 401 || statusCode == 403) {
        return AiUnauthorizedException(
          'AI unauthorized.',
          statusCode: statusCode,
        );
      }
      if (statusCode == 429) {
        return AiRateLimitException(
          'AI rate limited.',
          statusCode: statusCode,
          retryAfterSeconds: retryAfter,
        );
      }
      if (statusCode != null && statusCode >= 500) {
        return AiUnavailableException(
          'AI server unavailable.',
          statusCode: statusCode,
        );
      }
      return AiRequestException(
        'AI request failed.',
        statusCode: statusCode,
      );
    case DioExceptionType.cancel:
      return const AiUnavailableException('AI request cancelled.');
    case DioExceptionType.badCertificate:
      return AiUnavailableException(
        'AI connection rejected (bad certificate).',
        statusCode: statusCode,
      );
    case DioExceptionType.unknown:
      return AiUnavailableException(
        'AI request failed.',
        statusCode: statusCode,
      );
  }
}

String _normalizeBaseUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.replaceAll(RegExp(r'/+$'), '');
}

String _chatCompletionsPath(String baseUrl) {
  final normalized = baseUrl.replaceAll(RegExp(r'/+$'), '');
  if (normalized.endsWith('/v1')) return '/chat/completions';
  return '/v1/chat/completions';
}
