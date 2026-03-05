import 'package:dio/dio.dart';

import '../../domain/models/environment_snapshot.dart';
import 'environment_exceptions.dart';

class OpenWeatherClient {
  OpenWeatherClient({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio();

  final String _apiKey;
  final Dio _dio;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<EnvironmentSnapshot> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    if (!isConfigured) {
      throw StateError('OPENWEATHER_API_KEY is not configured');
    }

    late final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: <String, dynamic>{
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
    } on DioException catch (e, st) {
      Error.throwWithStackTrace(
        environmentFetchExceptionFromDio(e, provider: 'OpenWeather'),
        st,
      );
    }

    final data = response.data;
    if (data == null) {
      throw StateError('OpenWeather response was empty');
    }

    final main = data['main'] as Map<String, dynamic>?;
    final temp = (main?['temp'] as num?)?.toDouble();
    final humidity = (main?['humidity'] as num?)?.toInt();

    if (temp == null || humidity == null) {
      throw StateError('OpenWeather response missing temp/humidity');
    }

    return EnvironmentSnapshot(
      timestamp: DateTime.now(),
      tempC: temp,
      humidity: humidity,
    );
  }
}
