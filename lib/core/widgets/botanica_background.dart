import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/botanica_weather_mood.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/environment/weather_code.dart';
import '../../core/utils/motion_preferences.dart';

class BotanicaBackground extends StatelessWidget {
  const BotanicaBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
  });

  final Widget child;
  final double intensity;

  static String? _assetForWeather(WeatherKind kind) => switch (kind) {
        WeatherKind.clear => 'assets/illustrations/bg_weather_sunny.jpg',
        WeatherKind.partlyCloudy =>
          'assets/illustrations/bg_weather_cloudy.jpg',
        WeatherKind.cloudy => 'assets/illustrations/bg_weather_cloudy.jpg',
        WeatherKind.fog => 'assets/illustrations/bg_weather_cloudy.jpg',
        WeatherKind.drizzle => 'assets/illustrations/bg_weather_rainy.jpg',
        WeatherKind.rain => 'assets/illustrations/bg_weather_rainy.jpg',
        WeatherKind.snow => 'assets/illustrations/bg_weather_snowy.jpg',
        WeatherKind.thunder => 'assets/illustrations/bg_weather_thunder.jpg',
        WeatherKind.unknown => null,
      };

  static double _baseOpacityForWeather(WeatherKind kind) => switch (kind) {
        WeatherKind.clear => 0.30,
        WeatherKind.partlyCloudy => 0.26,
        WeatherKind.cloudy => 0.24,
        WeatherKind.fog => 0.22,
        WeatherKind.drizzle => 0.22,
        WeatherKind.rain => 0.20,
        WeatherKind.snow => 0.22,
        WeatherKind.thunder => 0.18,
        WeatherKind.unknown => 0.0,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final mood = Theme.of(context).extension<BotanicaWeatherMood>();
    final i = intensity.clamp(0.0, 1.0);
    final reduceMotion = botanicaReduceMotion(context);

    final glowA = mood?.glowA ?? scheme.primaryContainer;
    final glowB = mood?.glowB ?? scheme.tertiaryContainer;

    final kind = mood?.kind ?? WeatherKind.unknown;
    final artAsset = _assetForWeather(kind);

    final artOpacity =
        (_baseOpacityForWeather(kind) * (0.70 + (0.30 * i))).clamp(0.0, 0.45);
    final artTint =
        Color.lerp(scaffoldBg, scheme.surface, 0.65) ?? scheme.surface;

    final overlayTop =
        Color.lerp(scaffoldBg, scheme.surface, 0.50) ?? scaffoldBg;
    final overlayMid =
        Color.lerp(scaffoldBg, scheme.surface, 0.60) ?? scheme.surface;
    final overlayBottom = scheme.surface;

    final hasArt = artAsset != null && artOpacity > 0.0;
    final overlayAlpha = hasArt ? 0.90 : 1.0;

    return Stack(
      children: [
        if (hasArt)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? BotanicaTokens.motionMicroFast
                    : BotanicaTokens.motionSlow,
                switchInCurve: BotanicaTokens.curveReveal,
                switchOutCurve: BotanicaTokens.curveSettle,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Opacity(
                  key: ValueKey<String>(artAsset),
                  opacity: artOpacity,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 1.4,
                      sigmaY: 1.4,
                    ),
                    child: Image.asset(
                      artAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      excludeFromSemantics: true,
                      color: artTint.withValues(alpha: 0.55),
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ),
                ),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                overlayTop.withValues(alpha: overlayAlpha),
                overlayMid.withValues(alpha: overlayAlpha),
                overlayBottom.withValues(alpha: overlayAlpha),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        // Soft botanical "glow" layers.
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Align(
                  alignment: const Alignment(1.0, -0.85),
                  child: _BlurGlow(
                    color: glowA.withValues(alpha: 0.18 + (0.10 * i)),
                    size: 360 + (120 * i),
                    blur: 42 + (10 * i),
                  ),
                ),
                Align(
                  alignment: const Alignment(-1.0, 0.75),
                  child: _BlurGlow(
                    color: glowB.withValues(alpha: 0.14 + (0.10 * i)),
                    size: 440 + (180 * i),
                    blur: 48 + (14 * i),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: const SizedBox.expand(),
          ),
        ),
        child,
      ],
    );
  }
}

class _BlurGlow extends StatelessWidget {
  const _BlurGlow({
    required this.color,
    required this.size,
    required this.blur,
  });

  final Color color;
  final double size;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
