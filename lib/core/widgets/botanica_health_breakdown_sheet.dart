import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_health_score.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'botanica_sheet.dart';

class BotanicaHealthBreakdownSheet {
  BotanicaHealthBreakdownSheet._();

  static Future<void> show(BuildContext context, {required String plantId}) {
    return showBotanicaModalSheet<void>(
      context: context,
      builder: (ctx) => _BreakdownBody(plantId: plantId),
    );
  }
}

class _BreakdownBody extends ConsumerWidget {
  const _BreakdownBody({required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final breakdownAsync = ref.watch(plantHealthBreakdownProvider(plantId));

    return BotanicaSheetBody(
      top: 16,
      bottom: 24,
      includeKeyboardInset: false,
      child: breakdownAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (breakdown) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.healthBreakdownTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            BotanicaGaps.vXs,
            Center(
              child: Text(
                l10n.healthBreakdownSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            BotanicaGaps.vLg,
            ...breakdown.factors.map((factor) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: BotanicaTokens.spacingSm,
                  ),
                  child: _FactorRow(factor: factor),
                )),
            BotanicaGaps.vSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(BotanicaTokens.spacingSm),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(BotanicaTokens.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 20,
                    color: scheme.primary,
                  ),
                  BotanicaGaps.hSm,
                  Expanded(
                    child: Text(
                      l10n.healthBreakdownOverall(breakdown.totalScore),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor});

  final HealthFactor factor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final label = _factorLabel(l10n, factor.id);
    final icon = _factorIcon(factor.id);
    final progress = factor.maxPoints == 0
        ? 1.0
        : factor.points / factor.maxPoints;
    final color = progress >= 0.7
        ? scheme.primary
        : progress >= 0.4
            ? scheme.tertiary
            : scheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${factor.points}/${factor.maxPoints}',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(
                  color: scheme.outlineVariant.withValues(alpha: 0.25),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _factorLabel(AppLocalizations l10n, String id) =>
      switch (id) {
        'overdue' => l10n.healthFactorOverdue,
        'activity' => l10n.healthFactorActivity,
        'variety' => l10n.healthFactorVariety,
        'consistency' => l10n.healthFactorConsistency,
        _ => id,
      };

  static IconData _factorIcon(String id) => switch (id) {
        'overdue' => Icons.schedule_rounded,
        'activity' => Icons.trending_up_rounded,
        'variety' => Icons.category_rounded,
        'consistency' => Icons.check_circle_outline_rounded,
        _ => Icons.info_outline_rounded,
      };
}
