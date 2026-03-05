import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/botanica_tokens.dart';
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
        imagePath: 'assets/illustrations/onboarding_garden.jpg',
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
        imagePath: 'assets/illustrations/onboarding_smart_care.jpg',
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
        imagePath: 'assets/illustrations/onboarding_daily_flower.jpg',
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
      body: SafeArea(
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
              const SizedBox(height: 8),
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
              const SizedBox(height: 18),
              _Dots(
                count: pages.length,
                index: _pageIndex,
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 10),
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

    return Column(
      children: [
        Expanded(
          child: Container(
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
          )
              .animate(
                target: active ? 1 : 0,
              )
              .scale(
                begin: const Offset(0.97, 0.97),
                end: const Offset(1.0, 1.0),
                duration: 420.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 420.ms, delay: (index * 60).ms),
        ),
        const SizedBox(height: 22),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data.body,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.74),
            height: 1.45,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: BotanicaTokens.motionFast,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: selected ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.75)
                : scheme.outlineVariant.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
