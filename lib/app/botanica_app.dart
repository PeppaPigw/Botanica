import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/environment/weather_code.dart';
import '../gen/l10n/app_localizations.dart';
import 'routing/app_router.dart';
import 'theme/botanica_theme.dart';
import 'providers.dart';

class BotanicaApp extends ConsumerWidget {
  const BotanicaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      settingsControllerProvider.select((s) => s.locale),
    );
    final enableDynamicColor = ref.watch(
      settingsControllerProvider.select((s) => s.enableDynamicColor),
    );
    final router = ref.watch(goRouterProvider);
    ref.watch(taskRemindersSyncProvider);
    final environment = ref.watch(environmentControllerProvider);
    final weatherKind = weatherKindForWmoCode(environment.weatherCode);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = enableDynamicColor ? lightDynamic : null;
        final darkScheme = enableDynamicColor ? darkDynamic : null;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: BotanicaTheme.light(
            dynamicScheme: lightScheme,
            weatherKind: weatherKind,
          ),
          darkTheme: BotanicaTheme.dark(
            dynamicScheme: darkScheme,
            weatherKind: weatherKind,
          ),
          themeMode: ThemeMode.system,
          themeAnimationDuration: const Duration(milliseconds: 420),
          themeAnimationCurve: Curves.easeOutCubic,
          routerConfig: router,
        );
      },
    );
  }
}
