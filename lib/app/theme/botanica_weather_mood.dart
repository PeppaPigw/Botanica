import 'package:flutter/material.dart';

import '../../core/environment/weather_code.dart';

@immutable
class BotanicaWeatherMood extends ThemeExtension<BotanicaWeatherMood> {
  const BotanicaWeatherMood({
    required this.kind,
    required this.glowA,
    required this.glowB,
  });

  final WeatherKind kind;
  final Color glowA;
  final Color glowB;

  static BotanicaWeatherMood from({
    required ColorScheme scheme,
    required WeatherKind kind,
    required Brightness brightness,
  }) {
    if (kind == WeatherKind.unknown) {
      return BotanicaWeatherMood(
        kind: kind,
        glowA: scheme.primaryContainer,
        glowB: scheme.tertiaryContainer,
      );
    }

    final (tintA, tintB) = _tintsForKind(kind, brightness);
    final strengthA = brightness == Brightness.light ? 0.26 : 0.22;
    final strengthB = brightness == Brightness.light ? 0.22 : 0.18;

    return BotanicaWeatherMood(
      kind: kind,
      glowA: Color.lerp(scheme.primaryContainer, tintA, strengthA) ??
          scheme.primaryContainer,
      glowB: Color.lerp(scheme.tertiaryContainer, tintB, strengthB) ??
          scheme.tertiaryContainer,
    );
  }

  @override
  BotanicaWeatherMood copyWith({
    WeatherKind? kind,
    Color? glowA,
    Color? glowB,
  }) {
    return BotanicaWeatherMood(
      kind: kind ?? this.kind,
      glowA: glowA ?? this.glowA,
      glowB: glowB ?? this.glowB,
    );
  }

  @override
  BotanicaWeatherMood lerp(
      ThemeExtension<BotanicaWeatherMood>? other, double t) {
    if (other is! BotanicaWeatherMood) return this;
    return BotanicaWeatherMood(
      kind: t < 0.5 ? kind : other.kind,
      glowA: Color.lerp(glowA, other.glowA, t) ?? glowA,
      glowB: Color.lerp(glowB, other.glowB, t) ?? glowB,
    );
  }
}

(Color, Color) _tintsForKind(WeatherKind kind, Brightness brightness) {
  // These tints are *subtle*: they are blended into Botanica's existing
  // containers so the mood changes without breaking harmony.
  //
  // Light mode: slightly more vibrant; Dark mode: deeper, muted.
  switch (kind) {
    case WeatherKind.clear:
      return brightness == Brightness.light
          ? (const Color(0xFFF3D27A), const Color(0xFF9AD0FF))
          : (const Color(0xFF7A5A1D), const Color(0xFF1D4B6E));
    case WeatherKind.partlyCloudy:
      return brightness == Brightness.light
          ? (const Color(0xFFE7DCCF), const Color(0xFFBFD8E8))
          : (const Color(0xFF3A332B), const Color(0xFF23323B));
    case WeatherKind.cloudy:
      return brightness == Brightness.light
          ? (const Color(0xFFC9D2DA), const Color(0xFFAFC2CF))
          : (const Color(0xFF1E252B), const Color(0xFF1A2127));
    case WeatherKind.fog:
      return brightness == Brightness.light
          ? (const Color(0xFFD5DEE4), const Color(0xFFC6D4DB))
          : (const Color(0xFF1C2328), const Color(0xFF182024));
    case WeatherKind.drizzle:
      return brightness == Brightness.light
          ? (const Color(0xFF8FCBEA), const Color(0xFF7CD4B5))
          : (const Color(0xFF144A66), const Color(0xFF0B3A2D));
    case WeatherKind.rain:
      return brightness == Brightness.light
          ? (const Color(0xFF73B6E6), const Color(0xFF5FC0AF))
          : (const Color(0xFF123E5D), const Color(0xFF0A3A35));
    case WeatherKind.snow:
      return brightness == Brightness.light
          ? (const Color(0xFFE6F7FF), const Color(0xFFC3D8FF))
          : (const Color(0xFF1A2C34), const Color(0xFF1B2A3D));
    case WeatherKind.thunder:
      return brightness == Brightness.light
          ? (const Color(0xFFB9A2FF), const Color(0xFF78C4FF))
          : (const Color(0xFF2A1C4E), const Color(0xFF173B53));
    case WeatherKind.unknown:
      return (Colors.transparent, Colors.transparent);
  }
}
