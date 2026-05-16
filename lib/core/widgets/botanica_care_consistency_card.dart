import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_consistency_scorer.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareConsistencyCard extends StatelessWidget {
  const BotanicaCareConsistencyCard({
    super.key,
    required this.results,
    this.plantNameResolver,
  });

  final Map<String, CareConsistencyResult> results;
  final String Function(String plantId)? plantNameResolver;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sorted = results.entries.toList()
      ..sort((a, b) => b.value.score.compareTo(a.value.score));

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Care Consistency',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${sorted.length} plants',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...sorted.take(4).map((e) => _ConsistencyRow(
                plantId: e.key,
                result: e.value,
                scheme: scheme,
                nameResolver: plantNameResolver,
              )),
        ],
      ),
    );
  }
}

class _ConsistencyRow extends StatelessWidget {
  const _ConsistencyRow({
    required this.plantId,
    required this.result,
    required this.scheme,
    this.nameResolver,
  });

  final String plantId;
  final CareConsistencyResult result;
  final ColorScheme scheme;
  final String Function(String)? nameResolver;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gradeColor = switch (result.grade) {
      ConsistencyGrade.excellent => const Color(0xFF66BB6A),
      ConsistencyGrade.good => const Color(0xFF42A5F5),
      ConsistencyGrade.fair => const Color(0xFFFFA726),
      ConsistencyGrade.inconsistent => const Color(0xFFEF5350),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: gradeColor, shape: BoxShape.circle),
          ),
          BotanicaGaps.hXxs,
          Expanded(
            child: Text(
              nameResolver?.call(plantId) ?? plantId.substring(0, 6),
              style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${result.onTimePercentage.round()}%',
            style: textTheme.labelSmall?.copyWith(
              color: gradeColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
          if (result.improvingTrend) ...[
            BotanicaGaps.hXxs,
            const Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFF66BB6A)),
          ],
        ],
      ),
    );
  }
}
