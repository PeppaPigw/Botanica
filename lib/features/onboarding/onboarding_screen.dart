import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/botanica_ambient_background.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../gen/l10n/app_localizations.dart';
import 'permissions_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String location = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNextOrStart() {
    BotanicaHaptics.selectionTick();
    if (_pageIndex < 2) {
      _controller.nextPage(
        duration: BotanicaTokens.motionMedium,
        curve: Curves.easeOutCubic,
      );
      return;
    }
    context.go(PermissionsScreen.location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final pages = <_OnboardingPageData>[
      _OnboardingPageData(
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
        imagePath: 'assets/images/onboarding/onboarding_1.png',
        fallbackIcon: Icons.collections_bookmark_rounded,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.55),
            scheme.tertiaryContainer.withValues(alpha: 0.35),
          ],
        ),
      ),
      _OnboardingPageData(
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
        imagePath: 'assets/images/onboarding/onboarding_2.png',
        fallbackIcon: Icons.eco_rounded,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.secondaryContainer.withValues(alpha: 0.55),
            scheme.primaryContainer.withValues(alpha: 0.28),
          ],
        ),
      ),
      _OnboardingPageData(
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
        imagePath: 'assets/images/onboarding/onboarding_3.png',
        fallbackIcon: Icons.auto_awesome_rounded,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.tertiaryContainer.withValues(alpha: 0.55),
            scheme.primaryContainer.withValues(alpha: 0.28),
          ],
        ),
      ),
    ];

    return BotanicaPageScaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: BotanicaAmbientBackground(
              intensity: 0.06,
              speed: 0.4,
            ),
          ),
          SafeArea(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    key: const ValueKey('onboarding-skip'),
                    onPressed: () => context.go(PermissionsScreen.location),
                    child: Text(l10n.commonSkip),
                  ),
                ],
              ),
              BotanicaGaps.vXs,
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  itemBuilder: (context, index) => _OnboardingPage(
                    data: pages[index],
                    index: index,
                    active: index == _pageIndex,
                  ),
                ),
              ),
              BotanicaGaps.vBase,
              _Dots(
                count: pages.length,
                index: _pageIndex,
              ),
              BotanicaGaps.vBase,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('onboarding-continue'),
                  onPressed: _goNextOrStart,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusXL),
                    ),
                  ),
                  child: Text(_pageIndex < 2
                      ? l10n.commonContinue
                      : l10n.onboardingCta),
                ),
              ),
              BotanicaGaps.vSm,
              Text(
                l10n.appName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.imagePath,
    required this.fallbackIcon,
    required this.gradient,
  });

  final String title;
  final String body;
  final String imagePath;
  final IconData fallbackIcon;
  final Gradient gradient;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.active,
  });

  final _OnboardingPageData data;
  final int index;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final visual = Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            excludeFromSemantics: true,
            errorBuilder: (_, __, ___) => DecoratedBox(
              decoration: BoxDecoration(gradient: data.gradient),
              child: Center(
                child: Icon(
                  data.fallbackIcon,
                  size: 46,
                  color: scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  scheme.surface.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Expanded(
          child: visual.animateIfAllowed(
            context,
            (child) => child
                .animate(
                  target: active ? 1 : 0,
                )
                .scale(
                  begin: const Offset(0.97, 0.97),
                  end: const Offset(1.0, 1.0),
                  duration: BotanicaTokens.motionMedium,
                  curve: BotanicaTokens.curveReveal,
                )
                .fadeIn(
                  duration: BotanicaTokens.motionMedium,
                  delay: BotanicaTokens.motionStagger * index,
                  curve: BotanicaTokens.curveReveal,
                ),
          ),
        ),
        BotanicaGaps.vLg,
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        BotanicaGaps.vSm,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            data.body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.74),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final selected = i == index;
          return AnimatedContainer(
            duration: BotanicaTokens.motionMedium,
            curve: BotanicaTokens.curveReveal,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: selected ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        scheme.primary.withValues(alpha: 0.85),
                        scheme.tertiary.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: selected ? null : scheme.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
