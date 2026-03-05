import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
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
    await Future<void>.delayed(const Duration(milliseconds: 900));
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
                    _BrandMark(
                      tint: scheme.primary,
                    )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true, period: 3.seconds),
                        )
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.03, 1.03),
                          curve: Curves.easeInOut,
                        )
                        .fadeIn(duration: 650.ms, curve: Curves.easeOut),
                    const SizedBox(height: 22),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 520.ms)
                        .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    const SizedBox(height: 10),
                    Text(
                      l10n.splashTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                            height: 1.35,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 260.ms, duration: 520.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOutCubic),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          scheme.primary.withValues(alpha: 0.65),
                        ),
                      ),
                    ).animate().fadeIn(delay: 420.ms, duration: 480.ms),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.22),
            scheme.tertiaryContainer.withValues(alpha: 0.22),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            spreadRadius: -8,
            color: tint.withValues(alpha: 0.25),
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.spa_rounded,
          size: 38,
          color: scheme.onSurface.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
