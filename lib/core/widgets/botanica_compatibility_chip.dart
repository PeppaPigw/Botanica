import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_compatibility_checker.dart';
import 'botanica_gaps.dart';

class BotanicaCompatibilityChip extends StatelessWidget {
  const BotanicaCompatibilityChip({
    super.key,
    required this.result,
    required this.otherPlantName,
  });

  final CompatibilityResult result;
  final String otherPlantName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (IconData icon, Color color) = switch (result.verdict) {
      'excellent' => (Icons.favorite_rounded, scheme.tertiary),
      'good' => (Icons.thumb_up_rounded, scheme.primary),
      'fair' => (Icons.thumbs_up_down_rounded, const Color(0xFFFF9800)),
      _ => (Icons.warning_amber_rounded, scheme.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingSm,
        vertical: BotanicaTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          BotanicaGaps.hXs,
          Flexible(
            child: Text(
              '${result.verdict} match with $otherPlantName',
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
