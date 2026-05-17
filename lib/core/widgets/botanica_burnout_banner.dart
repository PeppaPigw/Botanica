import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_burnout_detector.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaBurnoutBanner extends StatefulWidget {
  const BotanicaBurnoutBanner({
    super.key,
    required this.report,
    this.onDismiss,
    this.onTapSuggestion,
  });

  final BurnoutReport report;
  final VoidCallback? onDismiss;
  final void Function(String suggestion)? onTapSuggestion;

  @override
  State<BotanicaBurnoutBanner> createState() => _BotanicaBurnoutBannerState();
}

class _BotanicaBurnoutBannerState extends State<BotanicaBurnoutBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: BotanicaTokens.motionSlow,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _dismissed = true);
      widget.onDismiss?.call();
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final isHigh = widget.report.riskLevel == 'burnoutHigh';
    final color = isHigh ? scheme.error : const Color(0xFFFF9800);

    return FadeTransition(
      opacity: _fadeIn,
      child: BotanicaGlassCard(
        accentColor: color,
        padding: BotanicaTokens.cardPaddingDense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusS),
                  ),
                  child: Icon(
                    isHigh
                        ? Icons.warning_rounded
                        : Icons.sentiment_neutral_rounded,
                    size: BotanicaTokens.iconSizeMd,
                    color: color,
                  ),
                ),
                BotanicaGaps.hSm,
                Expanded(
                  child: Text(
                    isHigh
                        ? l10n.careBurnoutOverload
                        : l10n.careBurnoutStretched,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _dismiss,
                  icon: Icon(
                    Icons.close_rounded,
                    size: BotanicaTokens.iconSizeSm,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (widget.report.suggestions.isNotEmpty) ...[
              BotanicaGaps.vXxs,
              Text(
                widget.report.suggestions.first,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
