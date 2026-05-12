import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../gen/l10n/app_localizations.dart';
import '../garden/garden_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String location = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeAfterDelay();
  }

  Future<void> _routeAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final hasOnboarded =
        ref.read(settingsControllerProvider).hasCompletedOnboarding;
    context
        .go(hasOnboarded ? GardenScreen.location : OnboardingScreen.location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final brandName = Text(
      l10n.appName,
      textAlign: TextAlign.center,
      style: GoogleFonts.fraunces(
        textStyle: Theme.of(context).textTheme.displaySmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );

    return BotanicaPageScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/splash_bg.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    scheme.surface.withValues(alpha: 0.82),
                    scheme.surface.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: BotanicaTokens.pagePadding,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    brandName.animateIfAllowed(
                      context,
                      (child) => child
                          .animate()
                          .fadeIn(
                            delay: BotanicaTokens.motionStagger,
                            duration: BotanicaTokens.motionSpring,
                            curve: BotanicaTokens.curveReveal,
                          )
                          .slideY(
                            begin: 0.01,
                            end: 0,
                            duration: BotanicaTokens.motionSpring,
                            curve: BotanicaTokens.curveReveal,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
