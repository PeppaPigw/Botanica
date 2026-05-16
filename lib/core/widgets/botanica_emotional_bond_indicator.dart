import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/emotional_bond_engine.dart';
import 'botanica_gaps.dart';

class BotanicaEmotionalBondIndicator extends StatelessWidget {
  const BotanicaEmotionalBondIndicator({
    super.key,
    required this.bond,
    this.compact = false,
  });

  final EmotionalBond bond;
  final bool compact;

  String _bondLabel(String type) => switch (type) {
        'bondSoulmate' => 'Soulmate',
        'bondBestFriend' => 'Best Friend',
        'bondCompanion' => 'Companion',
        'bondNewFriend' => 'New Friend',
        _ => 'Acquaintance',
      };

  IconData _bondIcon(String type) => switch (type) {
        'bondSoulmate' => Icons.favorite_rounded,
        'bondBestFriend' => Icons.people_rounded,
        'bondCompanion' => Icons.handshake_rounded,
        'bondNewFriend' => Icons.waving_hand_rounded,
        _ => Icons.person_outline_rounded,
      };

  Color _bondColor(String type, ColorScheme scheme) => switch (type) {
        'bondSoulmate' => scheme.error,
        'bondBestFriend' => scheme.tertiary,
        'bondCompanion' => scheme.primary,
        'bondNewFriend' => scheme.secondary,
        _ => scheme.outline,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _bondColor(bond.bondType, scheme);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_bondIcon(bond.bondType), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _bondLabel(bond.bondType),
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingSm,
        vertical: BotanicaTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_bondIcon(bond.bondType), size: 18, color: color),
          BotanicaGaps.hXs,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _bondLabel(bond.bondType),
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                '${bond.sharedMoments} shared moments',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
