import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/quick_check_in.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaQuickCheckInCard extends StatefulWidget {
  const BotanicaQuickCheckInCard({
    super.key,
    required this.plantNickname,
    required this.onResponse,
  });

  final String plantNickname;
  final ValueChanged<QuickCheckInResponse> onResponse;

  @override
  State<BotanicaQuickCheckInCard> createState() => _BotanicaQuickCheckInCardState();
}

class _BotanicaQuickCheckInCardState extends State<BotanicaQuickCheckInCard> {
  QuickCheckInResponse? _selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    if (_selected != null) {
      return BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 16,
                color: Color(0xFF66BB6A)),
            BotanicaGaps.hXs,
            Text(
              l10n.quickCheckInThanks,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.mood_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.quickCheckInTitle(widget.plantNickname),
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _ResponseButton(
                icon: Icons.sentiment_very_satisfied_rounded,
                label: l10n.quickCheckInThriving,
                color: const Color(0xFF66BB6A),
                onTap: () => _respond(QuickCheckInResponse.thriving),
                scheme: scheme,
                textTheme: textTheme,
              ),
              BotanicaGaps.hXs,
              _ResponseButton(
                icon: Icons.sentiment_neutral_rounded,
                label: l10n.quickCheckInOkay,
                color: const Color(0xFFFF9800),
                onTap: () => _respond(QuickCheckInResponse.okay),
                scheme: scheme,
                textTheme: textTheme,
              ),
              BotanicaGaps.hXs,
              _ResponseButton(
                icon: Icons.sentiment_dissatisfied_rounded,
                label: l10n.quickCheckInWorried,
                color: scheme.error,
                onTap: () => _respond(QuickCheckInResponse.worried),
                scheme: scheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _respond(QuickCheckInResponse response) {
    setState(() => _selected = response);
    widget.onResponse(response);
  }
}

class _ResponseButton extends StatelessWidget {
  const _ResponseButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.scheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
        child: InkWell(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: BotanicaTokens.spacingXs),
            child: Column(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
