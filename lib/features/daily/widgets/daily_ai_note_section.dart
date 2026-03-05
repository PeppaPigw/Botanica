import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/botanica_text_styles.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/models/daily_flower.dart';
import '../../../domain/models/enums.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../services/ai/ai_providers.dart';

class DailyAiNoteSection extends ConsumerWidget {
  const DailyAiNoteSection({
    super.key,
    required this.entry,
    required this.localeCode,
    required this.beliefMode,
    required this.variantLabel,
    required this.variantKey,
    required this.visible,
  });

  final DailyFlowerEntry entry;
  final String localeCode;
  final BeliefMode beliefMode;
  final String variantLabel;
  final String? variantKey;
  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) return const SizedBox.shrink();

    final settings = ref.watch(settingsControllerProvider);
    if (!settings.enableAiInsights) return const SizedBox.shrink();

    final ai = ref.read(botanicaAiServiceProvider);
    if (!ai.isConfigured) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final request = DailyAiNoteRequest(
      date: entry.date,
      localeCode: localeCode,
      beliefMode: beliefMode,
      variantLabel: variantLabel,
      variantKey: variantKey,
      content: entry.content,
    );

    final noteAsync = ref.watch(dailyAiNoteProvider(request));

    Widget cardChildForText(String text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: scheme.onSurface.withValues(alpha: 0.80),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.dailyAiNoteTitle,
                  style: context.tsTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: context.tsBodyMuted.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.76),
            ),
          ),
        ],
      );
    }

    return noteAsync.when(
      loading: () => Column(
        children: [
          const SizedBox(height: 14),
          BotanicaGlassCard(
            padding: const EdgeInsets.all(14),
            child:
                NoteSkeleton(color: scheme.onSurface.withValues(alpha: 0.10)),
          ),
        ],
      ).animate().fadeIn(duration: 240.ms),
      error: (_, __) => const SizedBox.shrink(),
      data: (text) {
        final value = text?.trim();
        if (value == null || value.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            const SizedBox(height: 14),
            BotanicaGlassCard(
              padding: const EdgeInsets.all(14),
              child: cardChildForText(value),
            )
                .animate()
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.03, curve: Curves.easeOutCubic),
          ],
        );
      },
    );
  }
}

class NoteSkeleton extends StatelessWidget {
  const NoteSkeleton({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget line(double w) {
      return FractionallySizedBox(
        widthFactor: w,
        child: Container(
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(0.52),
        const SizedBox(height: 12),
        line(0.95),
        const SizedBox(height: 10),
        line(0.78),
        const SizedBox(height: 10),
        line(0.86),
      ],
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1200.ms,
          color: scheme.onSurface.withValues(alpha: 0.08),
        );
  }
}
