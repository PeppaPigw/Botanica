import 'package:dio/dio.dart';

import '../../domain/models/environment_snapshot.dart';
import 'environment_exceptions.dart';

class OpenMeteoClient {
  OpenMeteoClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<EnvironmentSnapshot> fetchCurrent({
    required double lat,
    required double lon,
    String? timezone,
  }) async {
    final tz = (timezone == null || timezone.trim().isEmpty)
        ? 'auto'
        : timezone.trim();

    late final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: <String, dynamic>{
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,weather_code',
          'temperature_unit': 'celsius',
          'timezone': tz,
        },
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
    } on DioException catch (e, st) {
      Error.throwWithStackTrace(
        environmentFetchExceptionFromDio(e, provider: 'Open-Meteo'),
        st,
      );
    }

    final data = response.data;
    if (data == null) throw StateError('Open-Meteo response was empty');

    final current = data['current'] as Map<String, dynamic>?;
    if (current == null) throw StateError('Open-Meteo missing current section');

    final temp = (current['temperature_2m'] as num?)?.toDouble();
    final humidity = (current['relative_humidity_2m'] as num?)?.toInt();
    final code = (current['weather_code'] as num?)?.toInt();

    if (temp == null || humidity == null) {
      throw StateError('Open-Meteo missing temperature/humidity');
    }

    final time = DateTime.tryParse(current['time']?.toString() ?? '');

    return EnvironmentSnapshot(
      timestamp: time ?? DateTime.now(),
      tempC: temp,
      humidity: humidity,
      weatherCode: code,
      latitude: lat,
      longitude: lon,
    );
  }
}
