import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/botanica_tokens.dart';
import '../../../core/haptics/botanica_haptics.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../gen/l10n/app_localizations.dart';

String tarotLabel(AppLocalizations l10n, String id) => switch (id) {
      'the_fool' => l10n.tarotTheFool,
      'the_magician' => l10n.tarotTheMagician,
      'the_high_priestess' => l10n.tarotTheHighPriestess,
      'the_empress' => l10n.tarotTheEmpress,
      'the_emperor' => l10n.tarotTheEmperor,
      'the_hierophant' => l10n.tarotTheHierophant,
      'the_lovers' => l10n.tarotTheLovers,
      'the_chariot' => l10n.tarotTheChariot,
      'strength' => l10n.tarotStrength,
      'the_hermit' => l10n.tarotTheHermit,
      'wheel_of_fortune' => l10n.tarotWheelOfFortune,
      'justice' => l10n.tarotJustice,
      'the_hanged_man' => l10n.tarotTheHangedMan,
      'death' => l10n.tarotDeath,
      'temperance' => l10n.tarotTemperance,
      'the_devil' => l10n.tarotTheDevil,
      'the_tower' => l10n.tarotTheTower,
      'the_star' => l10n.tarotTheStar,
      'the_moon' => l10n.tarotTheMoon,
      'the_sun' => l10n.tarotTheSun,
      'judgement' => l10n.tarotJudgement,
      'the_world' => l10n.tarotTheWorld,
      _ => id,
    };

String tarotAssetForId(String id) {
  final normalized = id.trim().toLowerCase();
  if (normalized.isEmpty) return 'assets/placeholders/tarot/unknown.png';
  return 'assets/placeholders/tarot/$normalized.png';
}

class TarotVariantBadge extends StatelessWidget {
  const TarotVariantBadge({
    super.key,
    required this.label,
    required this.cardId,
  });

  final String label;
  final String cardId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        color: scheme.surface.withValues(alpha: 0.55),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 28,
              height: 40,
              child: Image.asset(
                tarotAssetForId(cardId),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/placeholders/tarot/unknown.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface.withValues(alpha: 0.78),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.t,
    required this.front,
    required this.back,
  });

  final double t;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    // Flip from 0° (back) → 180° (front). Swap the visible face at 90° and
    // rotate the front face back into view so it isn't mirrored.
    final clamped = t.clamp(0.0, 1.0);
    final angle = math.pi * clamped;
    final showFront = angle > (math.pi / 2);
    final displayed = showFront ? front : back;
    final displayAngle = showFront ? angle - math.pi : angle;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateY(displayAngle),
      child: displayed,
    );
  }
}

class TarotDrawFlowCard extends StatefulWidget {
  const TarotDrawFlowCard({
    super.key,
    required this.options,
    required this.onSelect,
  }) : assert(
          options.length == 4,
          'Tarot draw requires exactly four cards.',
        );

  final List<String> options;
  final Future<void> Function(String) onSelect;

  @override
  State<TarotDrawFlowCard> createState() => _TarotDrawFlowCardState();
}

class _TarotDrawFlowCardState extends State<TarotDrawFlowCard>
    with SingleTickerProviderStateMixin {
  bool _dealt = false;
  int _dealStep = 0;
  int? _pickedIndex;
  bool _saving = false;
  bool _dealing = false;

  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: BotanicaTokens.motionSpring,
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _beginDeal() async {
    if (_saving || _dealing || _dealt) return;

    BotanicaHaptics.primaryPress();
    setState(() {
      _dealt = true;
      _dealing = true;
      _dealStep = 0;
    });

    for (var i = 0; i < widget.options.length; i++) {
      await Future<void>.delayed(BotanicaTokens.motionFast);
      if (!mounted) return;
      setState(() => _dealStep = i + 1);
      BotanicaHaptics.selectionTick();
    }

    await Future<void>.delayed(BotanicaTokens.motionMicroFast);
    if (!mounted) return;
    setState(() => _dealing = false);
  }

  Future<void> _pick(int index) async {
    if (_saving || _dealing) return;
    if (_pickedIndex != null) return;
    if (index < 0 || index >= widget.options.length) return;

    BotanicaHaptics.revealClimax();
    setState(() {
      _pickedIndex = index;
      _saving = true;
    });

    await _revealController.forward(from: 0);

    final id = widget.options[index];
    await widget.onSelect(id);

    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget cardBack() {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.55),
              scheme.tertiaryContainer.withValues(alpha: 0.35),
              scheme.surface.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.style_rounded,
            color: scheme.onSurface.withValues(alpha: 0.70),
            size: 28,
          ),
        ),
      );
    }

    Widget cardFront(String id) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        child: Image.asset(
          tarotAssetForId(id),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/placeholders/tarot/unknown.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return BotanicaGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.style_rounded,
                color: scheme.onSurface.withValues(alpha: 0.80),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.dailyTarotDrawTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.dailyTarotDrawBody,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.70),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (!_dealt)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('tarot-draw-cta'),
                onPressed: _saving ? null : _beginDeal,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(l10n.dailyTarotDrawCta),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const aspectRatio = 0.66; // width / height (tarot-like)
                const spacing = 12.0;
                final rawWidth = (constraints.maxWidth - (spacing * 3)) /
                    widget.options.length;
                final cardWidth = rawWidth.clamp(72.0, 96.0);
                final cardHeight = cardWidth / aspectRatio;
                final totalHeight = cardHeight + 38;
                final deckLeft = (constraints.maxWidth - cardWidth) / 2;
                final deckTop = (totalHeight - cardHeight) / 2;

                const fanTurns = <double>[-0.022, -0.008, 0.008, 0.022];
                const fanXUnits = <double>[-1.15, -0.38, 0.38, 1.15];
                const fanYOffset = <double>[18, 6, 6, 18];
                final spreadX = cardWidth * 0.62;

                Offset targetForIndex(int index) {
                  final i = index.clamp(0, widget.options.length - 1);
                  return Offset(
                    deckLeft + (fanXUnits[i] * spreadX),
                    deckTop + fanYOffset[i],
                  );
                }

                Offset deckForIndex(int index) {
                  return Offset(
                    deckLeft + (index * 1.6),
                    deckTop + (index * 1.6),
                  );
                }

                Widget cardForIndex({
                  required int index,
                  required double revealT,
                }) {
                  final id = widget.options[index];
                  final selected = _pickedIndex == index;
                  final hasPick = _pickedIndex != null;
                  final dealt = _dealStep > index;

                  final basePos =
                      dealt ? targetForIndex(index) : deckForIndex(index);

                  final canTap =
                      dealt && !_dealing && !_saving && _pickedIndex == null;

                  final fadeOut = (hasPick && !selected)
                      ? (1 - revealT).clamp(0.0, 1.0)
                      : 1.0;

                  final translateY = (hasPick && !selected)
                      ? (36 + (cardHeight * 0.40) * revealT)
                      : 0.0;

                  final translateX = (hasPick && !selected)
                      ? ((index < (_pickedIndex ?? 0) ? -14 : 14) * revealT)
                      : 0.0;

                  final scale =
                      selected && hasPick ? (1 + (0.04 * revealT)) : 1.0;
                  final lift = selected && hasPick ? (-6.0 * revealT) : 0.0;

                  final turns =
                      dealt ? fanTurns[index] : (index.isEven ? -0.004 : 0.004);

                  Widget face() {
                    if (selected && hasPick) {
                      return _FlipCard(
                        t: revealT,
                        back: cardBack(),
                        front: cardFront(id),
                      );
                    }
                    return cardBack();
                  }

                  final child = AnimatedContainer(
                    duration: BotanicaTokens.motionMedium,
                    curve: BotanicaTokens.curveReveal,
                    width: cardWidth,
                    height: cardHeight,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusXL),
                      color: selected
                          ? scheme.primaryContainer.withValues(alpha: 0.30)
                          : scheme.surface.withValues(alpha: 0.72),
                      border: Border.all(
                        color: selected
                            ? scheme.primary.withValues(alpha: 0.58)
                            : scheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow
                              .withValues(alpha: selected ? 0.14 : 0.08),
                          blurRadius: selected ? 18 : 12,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: face(),
                  );

                  return AnimatedPositioned(
                    duration: BotanicaTokens.motionSlow,
                    curve: BotanicaTokens.curveReveal,
                    left: basePos.dx,
                    top: basePos.dy,
                    child: AnimatedRotation(
                      duration: BotanicaTokens.motionSlow,
                      curve: BotanicaTokens.curveReveal,
                      turns: turns,
                      child: AnimatedOpacity(
                        duration: BotanicaTokens.motionMedium,
                        curve: BotanicaTokens.curveReveal,
                        opacity: fadeOut,
                        child: Transform.translate(
                          offset: Offset(translateX, translateY + lift),
                          child: Transform.scale(
                            scale: scale,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                key: ValueKey('tarot-card-$index'),
                                borderRadius: BorderRadius.circular(
                                  BotanicaTokens.radiusXL,
                                ),
                                onTap: canTap ? () => _pick(index) : null,
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return AnimatedBuilder(
                  animation: _revealController,
                  builder: (context, _) {
                    final revealT = _pickedIndex == null
                        ? 0.0
                        : BotanicaTokens.curveSettle.transform(
                            _revealController.value,
                          );

                    final baseOrder = <int>[0, 3, 1, 2];
                    final picked = _pickedIndex;
                    final order = picked == null
                        ? baseOrder
                        : <int>[
                            for (final i in baseOrder)
                              if (i != picked) i,
                            picked,
                          ];

                    return SizedBox(
                      height: totalHeight,
                      child: Stack(
                        children: [
                          for (final index in order)
                            cardForIndex(index: index, revealT: revealT),
                          if (_pickedIndex == null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: -2,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      BotanicaTokens.radiusPill,
                                    ),
                                    color:
                                        scheme.surface.withValues(alpha: 0.68),
                                    border: Border.all(
                                      color: scheme.outlineVariant
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.dailyTarotCardLabel,
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.78),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
