import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_streak_badge.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/photos/share_card_export.dart';

class StreakShareCardScreen extends StatefulWidget {
  const StreakShareCardScreen({
    super.key,
    required this.streakDays,
    required this.plantCount,
  });

  final int streakDays;
  final int plantCount;

  static Future<void> open(
    BuildContext context, {
    required int streakDays,
    required int plantCount,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StreakShareCardScreen(
          streakDays: streakDays,
          plantCount: plantCount,
        ),
      ),
    );
  }

  @override
  State<StreakShareCardScreen> createState() => _StreakShareCardScreenState();
}

class _StreakShareCardScreenState extends State<StreakShareCardScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    final l10n = AppLocalizations.of(context);

    try {
      final file = await exportShareCardPng(
        repaintKey: _repaintKey,
        fileName: 'botanica-streak-${widget.streakDays}.png',
      );

      await Share.shareXFiles(
        [file],
        text: l10n.journalShareCardText,
      );
      BotanicaHaptics.completion();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.error),
              BotanicaGaps.hSm,
              Expanded(child: Text(l10n.journalShareFailed)),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.streakShareTitle),
        actions: [
          IconButton(
            onPressed: _sharing ? null : _share,
            icon: _sharing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(
                        scheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  )
                : const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            RepaintBoundary(
              key: _repaintKey,
              child: _StreakShareCard(
                streakDays: widget.streakDays,
                plantCount: widget.plantCount,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BotanicaTokens.spacingMd,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: const Icon(Icons.share_rounded),
                  label: Text(l10n.streakShareButton),
                ),
              ),
            ),
            BotanicaGaps.vMd,
          ],
        ),
      ),
    );
  }
}

class _StreakShareCard extends StatelessWidget {
  const _StreakShareCard({
    required this.streakDays,
    required this.plantCount,
  });

  final int streakDays;
  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF388E3C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BotanicaStreakBadge(
            streakDays: streakDays,
            size: 80,
            showLabel: false,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.streakShareCardDays(streakDays),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.streakShareCardSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.spa_rounded, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  'Botanica',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
