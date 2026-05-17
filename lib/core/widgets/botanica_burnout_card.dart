import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_burnout_detector.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaBurnoutCard extends StatelessWidget {
  const BotanicaBurnoutCard({
    super.key,
    required this.report,
  });

  final BurnoutReport report;

  @override
  Widget build(BuildContext context) {
    if (report.signals.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final riskColor = switch (report.riskLevel) {
      'high' => scheme.error,
      'medium' => const Color(0xFFFF9800),
      _ => const Color(0xFF66BB6A),
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  size: BotanicaTokens.iconSizeMd, color: riskColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.careLoadTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  report.riskLevel,
                  style: textTheme.labelSmall?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            child: LinearProgressIndicator(
              value: report.riskScore.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(riskColor),
            ),
          ),
          BotanicaGaps.vSm,
          ...report.signals.take(3).map((s) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 12, color: riskColor.withValues(alpha: 0.7)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        s.type.replaceAll('burnout', ''),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (report.suggestions.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            Text(
              report.suggestions.first,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
