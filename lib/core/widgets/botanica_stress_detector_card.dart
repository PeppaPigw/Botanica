import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/environment_stress_detector.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaStressDetectorCard extends StatelessWidget {
  const BotanicaStressDetectorCard({
    super.key,
    required this.results,
  });

  final List<PlantStressResult> results;

  @override
  Widget build(BuildContext context) {
    final stressed = results.where((r) => r.level != StressLevel.none).toList();
    if (stressed.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: BotanicaTokens.iconSizeMd, color: Color(0xFFFFA726)),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.stressAlertsTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${stressed.length} plants',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFFA726),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...stressed.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _levelColor(r.level),
                        shape: BoxShape.circle,
                      ),
                    ),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        r.plantNickname,
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      r.level.name,
                      style: textTheme.labelSmall?.copyWith(
                        color: _levelColor(r.level),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static Color _levelColor(StressLevel level) => switch (level) {
        StressLevel.none => const Color(0xFF66BB6A),
        StressLevel.mild => const Color(0xFFFFA726),
        StressLevel.moderate => const Color(0xFFFF7043),
        StressLevel.high => const Color(0xFFEF5350),
      };
}
