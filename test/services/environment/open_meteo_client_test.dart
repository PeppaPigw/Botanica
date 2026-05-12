import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/services/environment/open_meteo_client.dart';

Dio _mockDioWithResponse(Map<String, dynamic> data) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            data: data,
            statusCode: 200,
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('OpenMeteoClient', () {
    test('maps is_day == 0 to LightLevel.low regardless of cloud cover',
        () async {
      final dio = _mockDioWithResponse({
        'current': {
          'temperature_2m': 20.0,
          'relative_humidity_2m': 50,
          'weather_code': 1,
          'cloud_cover': 10, // low cloud cover, would normally be high light
          'is_day': 0, // night time
          'time': '2026-03-27T00:00:00Z',
        }
      });

      final client = OpenMeteoClient(dio: dio);
      final snapshot = await client.fetchCurrent(lat: 0, lon: 0);

      expect(snapshot.lightLevel, LightLevel.low);
    });

    test('maps cloud_cover < 30 to LightLevel.high during the day', () async {
      final dio = _mockDioWithResponse({
        'current': {
          'temperature_2m': 20.0,
          'relative_humidity_2m': 50,
          'weather_code': 1,
          'cloud_cover': 29,
          'is_day': 1,
          'time': '2026-03-27T12:00:00Z',
        }
      });

      final client = OpenMeteoClient(dio: dio);
      final snapshot = await client.fetchCurrent(lat: 0, lon: 0);

      expect(snapshot.lightLevel, LightLevel.high);
    });

    test('maps 30 <= cloud_cover < 70 to LightLevel.medium during the day',
        () async {
      final dio = _mockDioWithResponse({
        'current': {
          'temperature_2m': 20.0,
          'relative_humidity_2m': 50,
          'weather_code': 1,
          'cloud_cover': 50,
          'is_day': 1,
          'time': '2026-03-27T12:00:00Z',
        }
      });

      final client = OpenMeteoClient(dio: dio);
      final snapshot = await client.fetchCurrent(lat: 0, lon: 0);

      expect(snapshot.lightLevel, LightLevel.medium);
    });

    test('maps cloud_cover >= 70 to LightLevel.low during the day', () async {
      final dio = _mockDioWithResponse({
        'current': {
          'temperature_2m': 20.0,
          'relative_humidity_2m': 50,
          'weather_code': 1,
          'cloud_cover': 80,
          'is_day': 1,
          'time': '2026-03-27T12:00:00Z',
        }
      });

      final client = OpenMeteoClient(dio: dio);
      final snapshot = await client.fetchCurrent(lat: 0, lon: 0);

      expect(snapshot.lightLevel, LightLevel.low);
    });

    test('gracefully handles missing cloud_cover and is_day', () async {
      final dio = _mockDioWithResponse({
        'current': {
          'temperature_2m': 20.0,
          'relative_humidity_2m': 50,
          'weather_code': 1,
          // no cloud_cover or is_day
          'time': '2026-03-27T12:00:00Z',
        }
      });

      final client = OpenMeteoClient(dio: dio);
      final snapshot = await client.fetchCurrent(lat: 0, lon: 0);

      expect(snapshot.lightLevel, null);
    });
  });
}
