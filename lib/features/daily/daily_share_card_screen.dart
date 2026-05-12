import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../domain/models/daily_flower.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/photos/share_card_export.dart';

class DailyShareCardScreen extends StatefulWidget {
  const DailyShareCardScreen({
    super.key,
    required this.entry,
    required this.modeLabel,
    required this.variantLabel,
  });

  final DailyFlowerEntry entry;
  final String modeLabel;
  final String variantLabel;

  static Future<void> open(
    BuildContext context, {
    required DailyFlowerEntry entry,
    required String modeLabel,
    required String variantLabel,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DailyShareCardScreen(
          entry: entry,
          modeLabel: modeLabel,
          variantLabel: variantLabel,
        ),
      ),
    );
  }

  @override
  State<DailyShareCardScreen> createState() => _DailyShareCardScreenState();
}

class _DailyShareCardScreenState extends State<DailyShareCardScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    final l10n = AppLocalizations.of(context);

    try {
      final file = await exportShareCardPng(
        repaintKey: _repaintKey,
        fileName: 'botanica-daily-${_shareCardFileKey(widget.entry)}.png',
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
                  size: BotanicaTokens.iconSizeSm, color: Theme.of(context).colorScheme.error),
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
        title: Text(l10n.journalShareCardTitle),
        actions: [
          IconButton(
            key: const ValueKey('daily-share-card-share'),
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
            tooltip: l10n.dailyShare,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 18),
          child: Center(
            child: RepaintBoundary(
              key: _repaintKey,
              child: _DailyShareCard(
                entry: widget.entry,
                modeLabel: widget.modeLabel,
                variantLabel: widget.variantLabel,
                brandName: l10n.appName,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyShareCard extends StatelessWidget {
  const _DailyShareCard({
    required this.entry,
    required this.modeLabel,
    required this.variantLabel,
    required this.brandName,
  });

  final DailyFlowerEntry entry;
  final String modeLabel;
  final String variantLabel;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = entry.content;
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(
      entry.date,
    );

    String careLabel(String key) => switch (key) {
          'light' => l10n.careKeyLight,
          'water' => l10n.careKeyWater,
          'temperature' => l10n.careKeyTemperature,
          'petSafety' => l10n.careKeyPetSafety,
          _ => key,
        };

    Widget pill({required IconData icon, required String label}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: scheme.surface.withValues(alpha: 0.55),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: BotanicaTokens.iconSizeSm, color: scheme.onSurface.withValues(alpha: 0.72)),
            BotanicaGaps.hXxs,
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.74),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? scheme.outlineVariant.withValues(alpha: 0.64)
              : scheme.outlineVariant.withValues(alpha: 0.48),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isDark ? 0.32 : 0.16),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          width: 360,
          height: 450,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/illustrations/share_daily_bg.jpg',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              if ((content.imagePath ?? '').trim().isNotEmpty)
                Positioned(
                  right: -42,
                  top: 84,
                  bottom: 84,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.45,
                      child: Image.asset(
                        content.imagePath!.trim(),
                        width: 260,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            scheme.primaryContainer.withValues(alpha: 0.36),
                            scheme.tertiaryContainer.withValues(alpha: 0.24),
                            scheme.surface.withValues(alpha: 0.90),
                          ]
                        : [
                            scheme.primaryContainer.withValues(alpha: 0.55),
                            scheme.tertiaryContainer.withValues(alpha: 0.30),
                            scheme.surface.withValues(alpha: 0.92),
                          ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.26),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                            scheme.surface.withValues(alpha: 0.12),
                          ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                top: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    BotanicaGaps.vXxs,
                    Text(
                      dateLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    BotanicaGaps.vSm,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        pill(
                          icon: Icons.auto_awesome_rounded,
                          label: modeLabel,
                        ),
                        pill(
                          icon: Icons.tune_rounded,
                          label: variantLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Container(
                  padding: BotanicaTokens.cardPaddingDense,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: isDark
                        ? scheme.surfaceContainerHighest.withValues(alpha: 0.86)
                        : scheme.surface.withValues(alpha: 0.80),
                    border: Border.all(
                      color: scheme.outlineVariant
                          .withValues(alpha: isDark ? 0.58 : 0.45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: BotanicaTokens.iconSizeSm,
                            color: scheme.primary.withValues(alpha: 0.85),
                          ),
                          BotanicaGaps.hXs,
                          Expanded(
                            child: Text(
                              content.symbolism,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.82),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      BotanicaGaps.vSm,
                      Text(
                        l10n.dailyCareToday,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      BotanicaGaps.vXs,
                      ...content.careBasics.entries.take(4).map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• ${careLabel(e.key)}: ${e.value}',
                                style: textTheme.bodySmall?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.74),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                      BotanicaGaps.vSm,
                      Row(
                        children: [
                          Icon(
                            Icons.spa_rounded,
                            size: BotanicaTokens.iconSizeSm,
                            color: scheme.onSurface.withValues(alpha: 0.70),
                          ),
                          BotanicaGaps.hXxs,
                          Text(
                            brandName,
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _shareCardFileKey(DailyFlowerEntry entry) {
  final d = entry.date;
  final date = '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';
  final mode = entry.beliefMode.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
  final content = entry.content.key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
  return '$date-$mode-$content';
}
