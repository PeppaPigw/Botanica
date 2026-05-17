import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/environment/weather_code.dart';
import '../features/scan/scan_flow_screen.dart';
import '../gen/l10n/app_localizations.dart';
import '../services/quick_actions/quick_actions_service.dart';
import 'routing/app_router.dart';
import 'theme/botanica_tokens.dart';
import 'theme/botanica_theme.dart';
import 'providers.dart';

class BotanicaApp extends ConsumerStatefulWidget {
  const BotanicaApp({super.key});

  @override
  ConsumerState<BotanicaApp> createState() => _BotanicaAppState();
}

class _BotanicaAppState extends ConsumerState<BotanicaApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => ref.read(notificationsServiceProvider).clearBadge(),
    );
    ref.read(quickActionsServiceProvider).initialize();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(
      settingsControllerProvider.select((s) => s.locale),
    );
    final enableDynamicColor = ref.watch(
      settingsControllerProvider.select((s) => s.enableDynamicColor),
    );
    final router = ref.watch(goRouterProvider);
    notificationPlantIdCallback = (plantId) {
      router.push('/garden/plant/$plantId');
    };
    quickActionCallback = (action) {
      switch (action) {
        case QuickActionType.addPlant:
          router.go('/garden/add');
        case QuickActionType.waterNow:
          router.go('/garden/tasks');
        case QuickActionType.scanPlant:
          final ctx = router.routerDelegate.navigatorKey.currentContext;
          if (ctx != null) ScanFlowScreen.open(ctx);
      }
    };
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
          themeAnimationDuration: BotanicaTokens.motionSpring,
          themeAnimationCurve: BotanicaTokens.curveReveal,
          routerConfig: router,
        );
      },
    );
  }
}
