import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/room_microclimate_profiler.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaRoomProfileCard extends StatelessWidget {
  const BotanicaRoomProfileCard({
    super.key,
    required this.profiles,
  });

  final List<RoomProfile> profiles;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.room_preferences_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Room Profiles',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${profiles.length} rooms',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...profiles.take(3).map((p) => _RoomRow(profile: p, scheme: scheme)),
        ],
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({required this.profile, required this.scheme});

  final RoomProfile profile;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final healthColor = profile.avgHealthScore > 0.7
        ? const Color(0xFF66BB6A)
        : profile.avgHealthScore > 0.4
            ? const Color(0xFFFFA726)
            : scheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
          ),
          BotanicaGaps.hXs,
          Expanded(
            child: Text(
              profile.roomName.isEmpty ? 'Unassigned' : profile.roomName,
              style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${profile.plantCount} plants',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
          BotanicaGaps.hXs,
          Icon(
            _lightIcon(profile.dominantLight),
            size: 12,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  static IconData _lightIcon(String light) {
    return switch (light) {
      'bright' || 'direct' => Icons.wb_sunny_rounded,
      'indirect' || 'medium' => Icons.wb_cloudy_rounded,
      'low' || 'shade' => Icons.nightlight_round,
      _ => Icons.light_mode_rounded,
    };
  }
}
