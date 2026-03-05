import 'enums.dart';

class EnvironmentSnapshot {
  const EnvironmentSnapshot({
    required this.timestamp,
    required this.tempC,
    required this.humidity,
    this.weatherCode,
    this.latitude,
    this.longitude,
  });

  final DateTime timestamp;
  final double tempC;
  final int humidity;
  final int? weatherCode;
  final double? latitude;
  final double? longitude;

  Hemisphere? get derivedHemisphere {
    final lat = latitude;
    if (lat == null) return null;
    return lat >= 0 ? Hemisphere.northern : Hemisphere.southern;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp': timestamp.toIso8601String(),
        'tempC': tempC,
        'humidity': humidity,
        'weatherCode': weatherCode,
        'latitude': latitude,
        'longitude': longitude,
      };

  static EnvironmentSnapshot fromJson(Map<String, dynamic> json) =>
      EnvironmentSnapshot(
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        tempC: (json['tempC'] as num?)?.toDouble() ?? 22,
        humidity: (json['humidity'] as num?)?.toInt() ?? 50,
        weatherCode: (json['weatherCode'] as num?)?.toInt(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is EnvironmentSnapshot &&
      other.timestamp == timestamp &&
      other.tempC == tempC &&
      other.humidity == humidity &&
      other.weatherCode == weatherCode &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode =>
      Object.hash(timestamp, tempC, humidity, weatherCode, latitude, longitude);
}
