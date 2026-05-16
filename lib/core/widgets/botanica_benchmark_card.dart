import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_benchmark_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaBenchmarkCard extends StatelessWidget {
  const BotanicaBenchmarkCard({
    super.key,
    required this.benchmarks,
  });

  final List<PlantBenchmark> benchmarks;

  @override
  Widget build(BuildContext context) {
    if (benchmarks.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Community Benchmark',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...benchmarks.take(3).map((b) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        b.plantNickname,
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BotanicaTokens.spacingXs,
                        vertical: BotanicaTokens.spacingMicro,
                      ),
                      decoration: BoxDecoration(
                        color: _percentileColor(b.percentile).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                      ),
                      child: Text(
                        'Top ${b.percentile}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: _percentileColor(b.percentile),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static Color _percentileColor(int p) {
    if (p <= 25) return const Color(0xFFFFD700);
    if (p <= 50) return const Color(0xFF66BB6A);
    if (p <= 75) return const Color(0xFF42A5F5);
    return const Color(0xFFFFA726);
  }
}
