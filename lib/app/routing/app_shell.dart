import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/botanica_tokens.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/botanica_fab_location.dart';
import '../../core/widgets/botanica_nav_pill.dart';
import '../../core/widgets/botanica_scaffold.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/daily/daily_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/garden/garden_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../gen/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const List<String> _tabs = <String>[
    GardenScreen.location,
    CalendarScreen.location,
    DiscoverScreen.location,
    DailyScreen.location,
    ProfileScreen.location,
  ];

  int _indexFromLocation() {
    final index = _tabs.indexWhere((path) => location.startsWith(path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = _indexFromLocation();
    final reduceMotion = botanicaReduceMotion(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final horizontalInset = BotanicaTokens.pagePadding.left;
    final bottomExtra = viewPadding.bottom == 0
        ? BotanicaTokens.navPillBottomInsetNoSafeArea
        : BotanicaTokens.navPillBottomInsetWithSafeArea;
    final platform = Theme.of(context).platform;
    final effectiveSafeBottom = platform == TargetPlatform.iOS
        ? viewPadding.bottom
            .clamp(0.0, BotanicaTokens.navPillMaxSafeAreaInsetIOS)
            .toDouble()
        : viewPadding.bottom;

    final bgIntensity = switch (currentIndex) {
      0 => 1.0, // Garden
      1 => 0.96, // Calendar
      2 => 0.92, // Discover
      3 => 1.0, // Daily (ritual)
      _ => 0.82, // Profile/settings
    };

    final keyboardOpen = viewInsets.bottom > 0;

    return BotanicaScaffold(
      backgroundIntensity: bgIntensity,
      body: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : BotanicaTokens.motionMedium,
        switchInCurve: BotanicaTokens.curveReveal,
        switchOutCurve: BotanicaTokens.curveSettle,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey('tab-$currentIndex'),
          child: child,
        ),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push('${GardenScreen.location}/add'),
              tooltip: l10n.gardenAddPlantFab,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      floatingActionButtonLocation:
          currentIndex == 0 ? const BotanicaAlignedEndFabLocation() : null,
      bottomNavigationBar: AnimatedSwitcher(
        duration: BotanicaTokens.motionMedium,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: animation,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
        child: keyboardOpen
            ? const SizedBox.shrink(key: ValueKey('nav-hidden'))
            : Padding(
                key: const ValueKey('nav-visible'),
                padding: EdgeInsets.fromLTRB(
                  horizontalInset,
                  0,
                  horizontalInset,
                  effectiveSafeBottom + bottomExtra,
                ),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: BotanicaTokens.maxContentWidth,
                    ),
                    child: BotanicaNavPill(
                      currentIndex: currentIndex,
                      onSelect: (index) => context.go(_tabs[index]),
                      destinations: [
                        BotanicaNavDestination(
                          icon: Icons.spa_outlined,
                          selectedIcon: Icons.spa_rounded,
                          label: l10n.navGarden,
                          tooltip: l10n.navGarden,
                        ),
                        BotanicaNavDestination(
                          icon: Icons.calendar_month_outlined,
                          selectedIcon: Icons.calendar_month_rounded,
                          label: l10n.navCalendar,
                          tooltip: l10n.navCalendar,
                        ),
                        BotanicaNavDestination(
                          icon: Icons.search_rounded,
                          selectedIcon: Icons.search_rounded,
                          label: l10n.navDiscover,
                          tooltip: l10n.navDiscover,
                        ),
                        BotanicaNavDestination(
                          icon: Icons.auto_awesome_outlined,
                          selectedIcon: Icons.auto_awesome_rounded,
                          label: l10n.navDaily,
                          tooltip: l10n.navDaily,
                        ),
                        BotanicaNavDestination(
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: l10n.navProfile,
                          tooltip: l10n.navProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
