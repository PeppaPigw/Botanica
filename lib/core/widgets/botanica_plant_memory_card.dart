import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_memory_lane.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPlantMemoryCard extends StatelessWidget {
  const BotanicaPlantMemoryCard({
    super.key,
    required this.memory,
  });

  final PlantMemory memory;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            ),
            child: Icon(
              _memoryIcon(memory.type),
              size: BotanicaTokens.iconSizeSm,
              color: scheme.tertiary.withValues(alpha: 0.8),
            ),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _memoryTitle(memory.type, l10n),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _humanizeKey(memory.messageKey),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _memoryIcon(MemoryType type) {
    switch (type) {
      case MemoryType.firstPhoto:
        return Icons.camera_alt_outlined;
      case MemoryType.firstCare:
        return Icons.favorite_outline;
      case MemoryType.anniversaryMonth:
        return Icons.cake_outlined;
      case MemoryType.busiestDay:
        return Icons.local_fire_department_outlined;
      case MemoryType.longestGap:
        return Icons.hourglass_empty_rounded;
      case MemoryType.careComeback:
        return Icons.replay_rounded;
    }
  }

  static String _memoryTitle(MemoryType type, AppLocalizations l10n) {
    switch (type) {
      case MemoryType.firstPhoto:
        return l10n.plantMemoryFirstPhoto;
      case MemoryType.firstCare:
        return l10n.plantMemoryFirstCare;
      case MemoryType.anniversaryMonth:
        return l10n.plantMemoryAnniversary;
      case MemoryType.busiestDay:
        return l10n.plantMemoryBusiestDay;
      case MemoryType.longestGap:
        return l10n.plantMemoryLongestGap;
      case MemoryType.careComeback:
        return l10n.plantMemoryComeback;
    }
  }

  static String _humanizeKey(String key) {
    return key.replaceAll('_', ' ').replaceFirst(RegExp(r'^memory_'), '');
  }
}
