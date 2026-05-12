import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/botanica_text_styles.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/widgets/botanica_ai_note_card.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/models/daily_flower.dart';
import '../../../domain/models/enums.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/utils/motion_preferences.dart';
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
      return BotanicaAiNoteCard(
        title: l10n.dailyAiNoteTitle,
        textToCopy: text,
        copyTooltip: l10n.aiNoteCopyAction,
        copiedMessage: l10n.aiNoteCopied,
        titleStyle: context.tsTitle,
        child: Text(
          text,
          style: context.tsBodyMuted.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.76),
          ),
        ),
      );
    }

    return noteAsync.when(
      loading: () => Column(
        children: [
          BotanicaGaps.vSm,
          BotanicaGlassCard(
            padding: BotanicaTokens.cardPaddingDense,
            child:
                NoteSkeleton(color: scheme.onSurface.withValues(alpha: 0.10)),
          ),
        ],
      ).animateIfAllowed(
        context,
        (child) => child.animate().fadeIn(
              duration: BotanicaTokens.motionMedium,
              curve: BotanicaTokens.curveReveal,
            ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (text) {
        final value = text?.trim();
        if (value == null || value.isEmpty) return const SizedBox.shrink();

        final noteCard = BotanicaGlassCard(
          padding: BotanicaTokens.cardPaddingDense,
          child: cardChildForText(value),
        );

        return Column(
          children: [
            BotanicaGaps.vSm,
            noteCard.animateIfAllowed(
              context,
              (child) => child
                  .animate()
                  .fadeIn(
                    duration: BotanicaTokens.motionMedium,
                    curve: BotanicaTokens.curveReveal,
                  )
                  .slideY(
                    begin: 0.02,
                    end: 0,
                    duration: BotanicaTokens.motionMedium,
                    curve: BotanicaTokens.curveReveal,
                  ),
            ),
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

    final reduceMotion = botanicaReduceMotion(context);

    final skeleton = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(0.52),
        BotanicaGaps.vSm,
        line(0.95),
        BotanicaGaps.vSm,
        line(0.78),
        BotanicaGaps.vSm,
        line(0.86),
      ],
    );

    if (reduceMotion) return skeleton;

    return skeleton
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: BotanicaTokens.motionSlow * 3,
          color: scheme.onSurface.withValues(alpha: 0.08),
        );
  }
}
