import 'package:flutter/material.dart';

import '../../../app/theme/botanica_tokens.dart';

class DailyFlowerThumb extends StatelessWidget {
  const DailyFlowerThumb({
    super.key,
    required this.imagePath,
    this.size = 54,
  });

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: -4,
            color: scheme.primary.withValues(alpha: 0.10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/placeholders/white.png',
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
