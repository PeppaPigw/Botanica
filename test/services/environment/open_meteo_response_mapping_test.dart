import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/core/environment/weather_code.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/services/environment/open_meteo_client.dart';

Dio _dioWithResponse(Map<String, dynamic> data) {
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
  group('Open-Meteo response mapping', () {
    test('parses valid JSON response into EnvironmentSnapshot', () async {
      final client = OpenMeteoClient(
        dio: _dioWithResponse({
          'current': {
            'time': '2026-05-11T08:30:00Z',
            'temperature_2m': 21.7,
            'relative_humidity_2m': 63,
            'weather_code': 61,
            'cloud_cover': 18,
            'is_day': 1,
          },
        }),
      );

      final snapshot = await client.fetchCurrent(
        lat: 31.2304,
        lon: 121.4737,
        timezone: 'Asia/Shanghai',
      );

      expect(snapshot.timestamp, DateTime.parse('2026-05-11T08:30:00Z'));
      expect(snapshot.tempC, 21.7);
      expect(snapshot.humidity, 63);
      expect(snapshot.weatherCode, 61);
      expect(snapshot.latitude, 31.2304);
      expect(snapshot.longitude, 121.4737);
      expect(snapshot.lightLevel, LightLevel.high);
    });

    test('missing optional fields use safe defaults', () async {
      final client = OpenMeteoClient(
        dio: _dioWithResponse({
          'current': {
            'time': 'not-a-date',
          },
        }),
      );
      final before = DateTime.now();

      final snapshot = await client.fetchCurrent(lat: 1, lon: 2);

      expect(snapshot.tempC, 24);
      expect(snapshot.humidity, 48);
      expect(snapshot.weatherCode, isNull);
      expect(snapshot.lightLevel, isNull);
      expect(snapshot.timestamp.isBefore(before), isFalse);
    });

    test('weather code maps to WeatherKind enum', () {
      expect(weatherKindForWmoCode(0), WeatherKind.clear);
      expect(weatherKindForWmoCode(2), WeatherKind.partlyCloudy);
      expect(weatherKindForWmoCode(3), WeatherKind.cloudy);
      expect(weatherKindForWmoCode(45), WeatherKind.fog);
      expect(weatherKindForWmoCode(53), WeatherKind.drizzle);
      expect(weatherKindForWmoCode(61), WeatherKind.rain);
      expect(weatherKindForWmoCode(71), WeatherKind.snow);
      expect(weatherKindForWmoCode(95), WeatherKind.thunder);
      expect(weatherKindForWmoCode(null), WeatherKind.unknown);
    });
  });
}
