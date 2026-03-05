import 'package:flutter/material.dart';

/// A tiny mapper for Open‑Meteo's WMO `weather_code` → a UI-friendly bucket.
///
/// Open‑Meteo docs: https://open-meteo.com/en/docs
enum WeatherKind {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunder,
  unknown,
}

WeatherKind weatherKindForWmoCode(int? code) {
  if (code == null) return WeatherKind.unknown;

  if (code == 0) return WeatherKind.clear;

  if (code == 1 || code == 2) return WeatherKind.partlyCloudy;
  if (code == 3) return WeatherKind.cloudy;

  if (code == 45 || code == 48) return WeatherKind.fog;

  if (code >= 51 && code <= 57) return WeatherKind.drizzle;
  if (code >= 61 && code <= 67) return WeatherKind.rain;

  if (code >= 71 && code <= 77) return WeatherKind.snow;
  if (code == 85 || code == 86) return WeatherKind.snow;

  if (code >= 80 && code <= 82) return WeatherKind.rain;

  if (code >= 95 && code <= 99) return WeatherKind.thunder;

  return WeatherKind.unknown;
}

IconData iconForWeatherKind(WeatherKind kind) => switch (kind) {
      WeatherKind.clear => Icons.wb_sunny_rounded,
      WeatherKind.partlyCloudy => Icons.wb_cloudy_rounded,
      WeatherKind.cloudy => Icons.cloud_rounded,
      WeatherKind.fog => Icons.blur_on_rounded,
      WeatherKind.drizzle => Icons.grain_rounded,
      WeatherKind.rain => Icons.water_drop_rounded,
      WeatherKind.snow => Icons.ac_unit_rounded,
      WeatherKind.thunder => Icons.flash_on_rounded,
      WeatherKind.unknown => Icons.cloud_rounded,
    };
