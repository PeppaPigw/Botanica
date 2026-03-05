import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/environment/weather_code.dart';
import 'botanica_glass_theme.dart';
import 'botanica_tokens.dart';
import 'botanica_weather_mood.dart';

class BotanicaTheme {
  const BotanicaTheme._();

  static const Color seedColor = Color(0xFF0B3D2E); // deep leaf green

  static ThemeData light({
    ColorScheme? dynamicScheme,
    WeatherKind weatherKind = WeatherKind.unknown,
  }) {
    const scaffoldBg = Color(0xFFF6F5F0);
    const surface = Color(0xFFFBFAF6);

    final scheme = (dynamicScheme ??
            ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ))
        .copyWith(surface: surface);

    final textTheme = _textTheme(Brightness.light, scheme);
    final mood = BotanicaWeatherMood.from(
      scheme: scheme,
      kind: weatherKind,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.58),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingLg,
            vertical: BotanicaTokens.spacingMd,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingLg,
            vertical: BotanicaTokens.spacingMd,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: scheme.surface.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.9),
        contentPadding: BotanicaTokens.fieldPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.62),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? scheme.onSurface.withValues(alpha: 0.92)
                : scheme.onSurface.withValues(alpha: 0.72),
          );
        }),
        labelTextStyle: WidgetStatePropertyAll(
          (textTheme.labelLarge ?? textTheme.labelMedium)?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surface.withValues(alpha: 0.92),
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const BotanicaGlassTheme(
          primary: BotanicaGlassRecipe(
            blurSigma: BotanicaTokens.glassPrimaryBlur,
            backgroundOpacity: BotanicaTokens.glassPrimaryAlpha,
            borderOpacity: 0.55,
            shadowOpacity: 0.12,
            shadowBlurRadius: 30,
            shadowOffsetY: 18,
          ),
          secondary: BotanicaGlassRecipe(
            blurSigma: BotanicaTokens.glassSecondaryBlur,
            backgroundOpacity: BotanicaTokens.glassSecondaryAlpha,
            borderOpacity: 0.45,
            shadowOpacity: 0.10,
            shadowBlurRadius: 26,
            shadowOffsetY: 16,
          ),
          subtle: BotanicaGlassRecipe(
            blurSigma: BotanicaTokens.glassSubtleBlur,
            backgroundOpacity: BotanicaTokens.glassSubtleAlpha,
            borderOpacity: 0.40,
            shadowOpacity: 0.06,
            shadowBlurRadius: 18,
            shadowOffsetY: 12,
          ),
        ),
        mood,
      ],
    );
  }

  static ThemeData dark({
    ColorScheme? dynamicScheme,
    WeatherKind weatherKind = WeatherKind.unknown,
  }) {
    const scaffoldBg = Color(0xFF070B09);
    const surface = Color(0xFF0C1411);

    final scheme = (dynamicScheme ??
            ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ))
        .copyWith(surface: surface);

    final textTheme = _textTheme(Brightness.dark, scheme);
    final mood = BotanicaWeatherMood.from(
      scheme: scheme,
      kind: weatherKind,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.58),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingLg,
            vertical: BotanicaTokens.spacingMd,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingLg,
            vertical: BotanicaTokens.spacingMd,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: scheme.surface.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.72),
        contentPadding: BotanicaTokens.fieldPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.52),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? scheme.onSurface.withValues(alpha: 0.94)
                : scheme.onSurface.withValues(alpha: 0.70),
          );
        }),
        labelTextStyle: WidgetStatePropertyAll(
          (textTheme.labelLarge ?? textTheme.labelMedium)?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const BotanicaGlassTheme(
          primary: BotanicaGlassRecipe(
            blurSigma: 20,
            backgroundOpacity: 0.58,
            borderOpacity: 0.40,
            shadowOpacity: 0.22,
            shadowBlurRadius: 32,
            shadowOffsetY: 20,
          ),
          secondary: BotanicaGlassRecipe(
            blurSigma: 16,
            backgroundOpacity: 0.52,
            borderOpacity: 0.34,
            shadowOpacity: 0.20,
            shadowBlurRadius: 28,
            shadowOffsetY: 18,
          ),
          subtle: BotanicaGlassRecipe(
            blurSigma: 10,
            backgroundOpacity: 0.44,
            borderOpacity: 0.30,
            shadowOpacity: 0.14,
            shadowBlurRadius: 20,
            shadowOffsetY: 12,
          ),
        ),
        mood,
      ],
    );
  }

  static TextTheme _textTheme(Brightness brightness, ColorScheme scheme) {
    final base =
        (brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light())
            .textTheme;

    final ui = GoogleFonts.plusJakartaSansTextTheme(base);
    final editorial = GoogleFonts.frauncesTextTheme(base);

    final merged = ui.copyWith(
      displayLarge: editorial.displayLarge?.copyWith(
        fontSize: BotanicaTokens.displayLarge,
        height: 1.1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      displayMedium: editorial.displayMedium?.copyWith(
        fontSize: BotanicaTokens.displayMedium,
        height: 1.1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      displaySmall: editorial.displaySmall?.copyWith(
        fontSize: BotanicaTokens.displaySmall,
        height: 1.15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineLarge: editorial.headlineLarge?.copyWith(
        fontSize: BotanicaTokens.headlineLarge,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineMedium: editorial.headlineMedium?.copyWith(
        fontSize: BotanicaTokens.headlineMedium,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      headlineSmall: editorial.headlineSmall?.copyWith(
        fontSize: BotanicaTokens.headlineSmall,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleLarge: ui.titleLarge?.copyWith(
        fontSize: BotanicaTokens.titleLarge,
        height: 1.4,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: ui.titleMedium?.copyWith(
        fontSize: BotanicaTokens.titleMedium,
        height: 1.35,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      labelLarge: ui.labelLarge?.copyWith(
        fontSize: BotanicaTokens.labelLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.1,
      ),
      bodyLarge: ui.bodyLarge?.copyWith(
        fontSize: BotanicaTokens.bodyLarge,
        height: 1.45,
      ),
      bodyMedium: ui.bodyMedium?.copyWith(
        fontSize: BotanicaTokens.bodyMedium,
        height: 1.45,
      ),
      bodySmall: ui.bodySmall?.copyWith(
        fontSize: BotanicaTokens.bodySmall,
        height: 1.4,
      ),
    );

    return merged.apply(
      displayColor: scheme.onSurface,
      bodyColor: scheme.onSurface,
    );
  }
}
