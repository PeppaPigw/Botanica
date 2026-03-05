import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/services/environment/environment_exceptions.dart';
import 'package:botanica/services/environment/open_meteo_client.dart';
import 'package:botanica/services/environment/open_weather_client.dart';

Dio _dioRejecting({
  required DioExceptionType type,
  int? statusCode,
  Object? error,
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: type,
            error: error,
            response: statusCode == null
                ? null
                : Response<dynamic>(
                    requestOptions: options,
                    statusCode: statusCode,
                  ),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('Environment clients typed exceptions', () {
    test(
        'OpenMeteoClient throws EnvironmentOfflineException on connection errors',
        () async {
      final dio = _dioRejecting(
        type: DioExceptionType.connectionError,
        error: const SocketException('No route to host'),
      );

      final client = OpenMeteoClient(dio: dio);

      await expectLater(
        () => client.fetchCurrent(lat: 1, lon: 2),
        throwsA(
          isA<EnvironmentOfflineException>().having(
            (e) => e.endpoint,
            'endpoint',
            Uri.parse('https://api.open-meteo.com/v1/forecast'),
          ),
        ),
      );
    });

    test('OpenMeteoClient throws EnvironmentTimeoutException on timeouts',
        () async {
      final dio = _dioRejecting(type: DioExceptionType.receiveTimeout);
      final client = OpenMeteoClient(dio: dio);

      await expectLater(
        () => client.fetchCurrent(lat: 1, lon: 2),
        throwsA(isA<EnvironmentTimeoutException>()),
      );
    });

    test(
        'OpenWeatherClient throws EnvironmentClientErrorException for 4xx and redacts query params',
        () async {
      final dio = _dioRejecting(
        type: DioExceptionType.badResponse,
        statusCode: 401,
      );

      final client = OpenWeatherClient(
        apiKey: 'test-key',
        dio: dio,
      );

      await expectLater(
        () => client.fetchCurrent(lat: 1, lon: 2),
        throwsA(
          isA<EnvironmentClientErrorException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.endpoint,
                'endpoint',
                Uri.parse('https://api.openweathermap.org/data/2.5/weather'),
              ),
        ),
      );
    });
  });
}
