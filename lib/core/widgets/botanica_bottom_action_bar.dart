import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import 'glass_card.dart';

class BotanicaBottomActionBar extends StatelessWidget {
  const BotanicaBottomActionBar({
    super.key,
    required this.child,
    this.tier = GlassTier.secondary,
  });

  final Widget child;
  final GlassTier tier;

  static double clearanceFor(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomExtra = viewPadding.bottom == 0
        ? BotanicaTokens.navPillBottomInsetNoSafeArea
        : BotanicaTokens.navPillBottomInsetWithSafeArea;
    return BotanicaTokens.navPillHeight +
        bottomExtra +
        BotanicaTokens.bottomChromeGap;
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final horizontalInset = BotanicaTokens.pagePadding.left;
    final keyboardOpen = viewInsets.bottom > 0;
    final platform = Theme.of(context).platform;

    final bottomExtra = viewPadding.bottom == 0
        ? BotanicaTokens.navPillBottomInsetNoSafeArea
        : BotanicaTokens.navPillBottomInsetWithSafeArea;

    final effectiveSafeBottom = platform == TargetPlatform.iOS
        ? viewPadding.bottom
            .clamp(0.0, BotanicaTokens.navPillMaxSafeAreaInsetIOS)
            .toDouble()
        : viewPadding.bottom;

    final bottomPadding = keyboardOpen
        ? BotanicaTokens.spacingSm
        : effectiveSafeBottom + bottomExtra;

    return AnimatedPadding(
      duration: BotanicaTokens.motionMedium,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardOpen ? viewInsets.bottom : 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalInset,
          0,
          horizontalInset,
          bottomPadding,
        ),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: BotanicaTokens.maxContentWidth,
            ),
            child: BotanicaGlassCard(
              tier: tier,
              borderRadius: BotanicaTokens.radiusPill,
              padding: const EdgeInsets.all(BotanicaTokens.spacingXxs),
              child: SizedBox(
                height: 56,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
