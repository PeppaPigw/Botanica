import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_memory_lane.dart';
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
                  _memoryTitle(memory.type),
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

  static String _memoryTitle(MemoryType type) {
    switch (type) {
      case MemoryType.firstPhoto:
        return 'First Photo';
      case MemoryType.firstCare:
        return 'First Care';
      case MemoryType.anniversaryMonth:
        return 'Anniversary';
      case MemoryType.busiestDay:
        return 'Busiest Day';
      case MemoryType.longestGap:
        return 'Longest Gap';
      case MemoryType.careComeback:
        return 'Comeback';
    }
  }

  static String _humanizeKey(String key) {
    return key.replaceAll('_', ' ').replaceFirst(RegExp(r'^memory_'), '');
  }
}
