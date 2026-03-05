import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_text_styles.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/utils/motion_preferences.dart';
import '../../domain/models/daily_flower.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/daily_flower_mode.dart';
import '../../domain/services/daily_rituals.dart';
import '../../domain/services/zodiac.dart';
import '../../gen/l10n/app_localizations.dart';
import '../profile/profile_screen.dart';
import 'daily_share_card_screen.dart';
import 'widgets/daily_ai_note_section.dart';
import 'widgets/daily_flower_card.dart';
import 'widgets/mode_reveal_interaction.dart';
import 'widgets/omikuji_helpers.dart';
import 'widgets/tarot_helpers.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  static const String location = '/daily';

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  bool _revealed = false;
  DateTime? _lastDay;
  BeliefMode? _lastBeliefMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (botanicaReduceMotion(context)) {
      if (_controller.isAnimating) _controller.stop();
    } else {
      if (!_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = botanicaReduceMotion(context);

    final settings = ref.watch(settingsControllerProvider);
    final repo = ref.read(dailyFlowerRepositoryProvider);
    final selector = ref.read(dailyFlowerSelectorProvider);

    final localeCode =
        settings.localeCode ?? Localizations.localeOf(context).languageCode;
    final beliefMode = settings.beliefMode;
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    // Reset the reveal state when the day changes or the user switches modes.
    // This keeps the Daily ritual feeling intentional and avoids stale states
    // when navigating between tabs.
    if (_lastDay == null || !_isSameDay(_lastDay!, day)) {
      _revealed = false;
      _lastDay = day;
    }
    if (_lastBeliefMode == null || _lastBeliefMode != beliefMode) {
      _revealed = false;
      _lastBeliefMode = beliefMode;
    }

    final tarotCardId = beliefMode == BeliefMode.tarot
        ? ref.read(dailyDrawsRepositoryProvider).readTarotCardIdForDate(now)
        : null;

    final variantKey = DailyFlowerMode.variantKey(
      beliefMode: beliefMode,
      settings: settings,
      now: now,
      tarotCardId: tarotCardId,
    );

    final personalizationKey = DailyFlowerMode.personalizationKey(settings);
    final hasSeed = (settings.dailySeed ?? '').trim().isNotEmpty;
    final birthDate = settings.birthDate;
    final birthSignId = (!hasSeed && birthDate != null)
        ? westernZodiacIdForDate(birthDate)
        : null;
    final personalKeyLabel =
        birthSignId == null ? null : _westernZodiacLabel(l10n, birthSignId);

    final variantLabel = _variantLabel(
      l10n: l10n,
      localeCode: localeCode,
      beliefMode: beliefMode,
      now: now,
      variantKey: variantKey,
      personalKeyLabel: personalKeyLabel,
      personalizationKey: personalizationKey,
    );

    final modeSelected = beliefMode != BeliefMode.unselected;
    final needsPersonalInfo = DailyFlowerMode.needsPersonalInfo(
      beliefMode: beliefMode,
      settings: settings,
    );
    final needsTarotDraw = DailyFlowerMode.needsTarotDraw(
      beliefMode: beliefMode,
      tarotCardId: tarotCardId,
    );
    final canShowEntry = DailyFlowerMode.canShowEntry(
      beliefMode: beliefMode,
      needsPersonalInfo: needsPersonalInfo,
      needsTarotDraw: needsTarotDraw,
    );
    final profileMissingBody = beliefMode == BeliefMode.westernZodiac
        ? l10n.dailyProfileMissingBodyZodiac
        : l10n.dailyProfileMissingBody;

    return SafeArea(
      child: Stack(
        children: [
          if (!reduceMotion)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _PetalPainter(
                    t: _controller.value,
                    color: scheme.tertiary.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
          ListView(
            padding: BotanicaTokens.pagePaddingWithBottomNav(context),
            children: [
              BotanicaScreenTitle(l10n.navDaily)
                  .animate()
                  .fadeIn(duration: 380.ms),
              BotanicaGaps.vSm,
              BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: Row(
                  children: [
                    Icon(
                      beliefModeIcon(beliefMode),
                      color: scheme.onSurface.withValues(alpha: 0.80),
                    ),
                    BotanicaGaps.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _modeLabel(l10n, beliefMode),
                            style: context.tsTitle,
                          ),
                          BotanicaGaps.vMicro,
                          Text(
                            variantLabel,
                            style: context.tsBodyMuted.copyWith(
                              fontSize: BotanicaTokens.bodySmall,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.dailyInfoTitle,
                          onPressed: () => _showModeInfoSheet(
                            beliefMode: beliefMode,
                            variantLabel: variantLabel,
                          ),
                          icon: Icon(
                            Icons.info_outline_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.78),
                          ),
                        ),
                        BotanicaButton(
                          onPressed: () => context.go(ProfileScreen.location),
                          variant: BotanicaButtonVariant.text,
                          label: l10n.commonEdit,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 420.ms),
              if (!modeSelected) ...[
                const SizedBox(height: 12),
                BotanicaGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.82),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.dailyModeMissingTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.dailyModeMissingBody,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.70),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go(ProfileScreen.location),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(l10n.dailyModeMissingCta),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
              ] else if (needsPersonalInfo) ...[
                const SizedBox(height: 12),
                BotanicaGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.80),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.dailyProfileMissingTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profileMissingBody,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.70),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go(ProfileScreen.location),
                          icon: const Icon(Icons.tune_rounded),
                          label: Text(l10n.dailyProfileMissingCta),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
              ] else if (needsTarotDraw) ...[
                const SizedBox(height: 12),
                TarotDrawFlowCard(
                  key: const ValueKey('tarot-draw-flow'),
                  options: DailyRituals.tarotDrawOptions(now),
                  onSelect: (id) async {
                    await ref
                        .read(dailyDrawsRepositoryProvider)
                        .writeTarotCardIdForDate(date: now, cardId: id);
                    if (!mounted) return;
                    setState(() => _revealed = true);
                  },
                ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
              ],
              if (canShowEntry) ...[
                const SizedBox(height: 16),
                FutureBuilder(
                  future: repo.loadPool(localeCode),
                  builder: (context, snapshot) {
                    final pool = snapshot.data ?? const <DailyFlowerContent>[];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return BotanicaGlassCard(
                        child: SizedBox(
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                scheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError || pool.isEmpty) {
                      return BotanicaStateCard(
                        icon: Icons.cloud_off_rounded,
                        title: l10n.dailyContentUnavailableTitle,
                        body: l10n.dailyContentUnavailableBody,
                        primaryAction: OutlinedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.commonTryAgain),
                        ),
                      );
                    }

                    final entry = selector.select(
                      date: now,
                      localeCode: localeCode,
                      beliefMode: beliefMode,
                      variantKey: variantKey,
                      personalizationKey: personalizationKey,
                      pool: pool,
                    );

                    final favoritesRepo =
                        ref.read(dailyFavoritesRepositoryProvider);
                    final favoritesKeys =
                        ref.watch(dailyFavoritesKeysProvider).valueOrNull;
                    final favoriteKey = favoritesRepo.keyFor(
                      entry: entry,
                      variantKey: variantKey,
                    );
                    final isSaved = favoritesKeys?.contains(favoriteKey) ??
                        favoritesRepo.isSaved(favoriteKey);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DailyFlowerCard(
                          key: const ValueKey('daily-flower-card'),
                          entry: entry,
                          variantLabel: variantLabel,
                          variantKey: variantKey,
                          revealed: _revealed,
                          onReveal: () => setState(() => _revealed = true),
                        )
                            .animate()
                            .fadeIn(duration: 420.ms)
                            .slideY(begin: 0.06, curve: Curves.easeOutCubic),
                        DailyAiNoteSection(
                          entry: entry,
                          localeCode: localeCode,
                          beliefMode: beliefMode,
                          variantLabel: variantLabel,
                          variantKey: variantKey,
                          visible: _revealed,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: !_revealed
                                    ? null
                                    : () async {
                                        BotanicaHaptics.selectionTick();
                                        await favoritesRepo.toggleSaved(
                                          entry: entry,
                                          variantKey: variantKey,
                                        );
                                      },
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark_added_rounded
                                      : Icons.bookmark_add_rounded,
                                ),
                                label: Text(l10n.dailySave),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      BotanicaTokens.radiusXL,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                key: const ValueKey('daily-share-btn'),
                                onPressed: !_revealed
                                    ? null
                                    : () => DailyShareCardScreen.open(
                                          context,
                                          entry: entry,
                                          modeLabel:
                                              _modeLabel(l10n, beliefMode),
                                          variantLabel: variantLabel,
                                        ),
                                icon: const Icon(Icons.ios_share_rounded),
                                label: Text(l10n.dailyShare),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      BotanicaTokens.radiusXL,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 160.ms, duration: 420.ms),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                BotanicaGlassCard(
                  tier: GlassTier.subtle,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.80)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.dailyDeterministicNote,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 220.ms, duration: 420.ms),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showModeInfoSheet({
    required BeliefMode beliefMode,
    required String variantLabel,
  }) async {
    final l10n = AppLocalizations.of(context);
    final modeLabel = _modeLabel(l10n, beliefMode);
    final hint = _revealHint(l10n, beliefMode);

    String modeBody() => switch (beliefMode) {
          BeliefMode.unselected => l10n.dailyModeMissingBody,
          BeliefMode.westernZodiac => l10n.dailyInfoModeWesternZodiac,
          BeliefMode.tarot => l10n.dailyInfoModeTarot,
          BeliefMode.almanac ||
          BeliefMode.omikuji ||
          BeliefMode.runes ||
          BeliefMode.ogham =>
            l10n.dailyInfoModeAuto(modeLabel),
          BeliefMode.justFlower => l10n.dailyInfoModeJustFlower,
        };

    await showBotanicaModalSheet<void>(
      context: context,
      useSafeArea: false,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final scheme = Theme.of(sheetContext).colorScheme;
        final textTheme = Theme.of(sheetContext).textTheme;

        return BotanicaSheetBody(
          top: 10,
          bottom: 18,
          includeKeyboardInset: false,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.80)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.dailyInfoTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.commonClose,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BotanicaGlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modeLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      variantLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.70),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.dailyInfoIntro,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      modeBody(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.dailyInfoHowToReveal(hint),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.70),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.go(ProfileScreen.location);
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(l10n.dailyInfoChangeMode),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusXL),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _revealHint(AppLocalizations l10n, BeliefMode mode) => switch (mode) {
      BeliefMode.tarot => l10n.dailyRevealHintFlip,
      BeliefMode.westernZodiac => l10n.dailyRevealHintSlide,
      BeliefMode.almanac => l10n.dailyRevealHintStamp,
      BeliefMode.omikuji => l10n.dailyRevealHintPull,
      BeliefMode.runes => l10n.dailyRevealHintHold,
      BeliefMode.ogham => l10n.dailyRevealHintTrace,
      BeliefMode.justFlower => l10n.dailyRevealHintTap,
      BeliefMode.unselected => l10n.dailyRevealHintTap,
    };

class _PetalPainter extends CustomPainter {
  const _PetalPainter({
    required this.t,
    required this.color,
  });

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final random = Random(42);

    for (var i = 0; i < 14; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final driftX = sin((t * 2 * pi) + i) * 18;
      final driftY = cos((t * 2 * pi) + i) * 26;

      final center = Offset(baseX + driftX, baseY + driftY);
      final r = 10.0 + (random.nextDouble() * 18);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}

String _variantLabel({
  required AppLocalizations l10n,
  required String localeCode,
  required BeliefMode beliefMode,
  required DateTime now,
  required String? variantKey,
  required String? personalKeyLabel,
  required String? personalizationKey,
}) {
  final key = variantKey?.trim();
  return switch (beliefMode) {
    BeliefMode.unselected => l10n.profileDailyProfileNotSet,
    BeliefMode.westernZodiac => key == null || key.isEmpty
        ? l10n.profileDailyProfileNotSet
        : _westernZodiacLabel(l10n, key),
    BeliefMode.tarot => key == null || key.isEmpty
        ? l10n.dailyTarotNotDrawn
        : tarotLabel(l10n, key),
    BeliefMode.almanac => () {
        final ganzhi = DailyRituals.almanacGanzhiForDate(now);
        return localeCode.toLowerCase().startsWith('zh')
            ? ganzhi.labelZh
            : ganzhi.labelEn;
      }(),
    BeliefMode.omikuji =>
      omikujiLabel(l10n, DailyRituals.omikujiIdForDate(now)),
    BeliefMode.runes => () {
        final rune = DailyRituals.runeForId(DailyRituals.runeIdForDate(now));
        return '${rune.glyph} ${rune.name}';
      }(),
    BeliefMode.ogham => _titleCase(DailyRituals.oghamIdForDate(now)),
    BeliefMode.justFlower => (personalKeyLabel ?? '').trim().isNotEmpty
        ? personalKeyLabel!.trim()
        : ((personalizationKey ?? '').trim().isEmpty
            ? l10n.profileDailyProfileNotSet
            : l10n.profileDailySeedTitle),
  };
}

String _modeLabel(AppLocalizations l10n, BeliefMode mode) => switch (mode) {
      BeliefMode.unselected => l10n.beliefModeNotSet,
      BeliefMode.westernZodiac => l10n.beliefModeWesternZodiac,
      BeliefMode.tarot => l10n.beliefModeTarot,
      BeliefMode.almanac => l10n.beliefModeAlmanac,
      BeliefMode.omikuji => l10n.beliefModeOmikuji,
      BeliefMode.runes => l10n.beliefModeRunes,
      BeliefMode.ogham => l10n.beliefModeOgham,
      BeliefMode.justFlower => l10n.beliefModeJustFlower,
    };

String _westernZodiacLabel(AppLocalizations l10n, String id) => switch (id) {
      'aries' => l10n.zodiacAries,
      'taurus' => l10n.zodiacTaurus,
      'gemini' => l10n.zodiacGemini,
      'cancer' => l10n.zodiacCancer,
      'leo' => l10n.zodiacLeo,
      'virgo' => l10n.zodiacVirgo,
      'libra' => l10n.zodiacLibra,
      'scorpio' => l10n.zodiacScorpio,
      'sagittarius' => l10n.zodiacSagittarius,
      'capricorn' => l10n.zodiacCapricorn,
      'aquarius' => l10n.zodiacAquarius,
      'pisces' => l10n.zodiacPisces,
      _ => id,
    };

String _titleCase(String input) {
  final s = input.trim();
  if (s.isEmpty) return s;
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
