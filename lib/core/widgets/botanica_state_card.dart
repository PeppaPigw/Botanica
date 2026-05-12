import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_semantics.dart';
import '../../app/theme/botanica_tokens.dart';
import 'glass_card.dart';

class BotanicaStateCard extends StatelessWidget {
  const BotanicaStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tier = GlassTier.secondary,
    this.illustrationAsset,
    this.primaryAction,
    this.secondaryAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final GlassTier tier;
  final String? illustrationAsset;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BotanicaGlassCard(
      tier: tier,
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (illustrationAsset != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      illustrationAsset!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      excludeFromSemantics: true,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            scheme.surface.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: BotanicaTokens.spacingBase),
          ],
          Row(
            children: [
              Icon(icon, color: scheme.onSurface.withValues(alpha: 0.82)),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: BotanicaSemantics.textStyle(
                      context, BotanicaTextRole.title),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingXs),
          Text(
            body,
            style:
                BotanicaSemantics.textStyle(context, BotanicaTextRole.bodyMuted)
                    .copyWith(height: 1.35),
          ),
          if (primaryAction != null || secondaryAction != null) ...[
            const SizedBox(height: BotanicaTokens.spacingBase),
            Row(
              children: [
                if (secondaryAction != null) ...[
                  Expanded(child: secondaryAction!),
                  if (primaryAction != null)
                    const SizedBox(width: BotanicaTokens.spacingSm),
                ],
                if (primaryAction != null) Expanded(child: primaryAction!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
