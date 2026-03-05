import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/botanica_tokens.dart';
import '../../../core/haptics/botanica_haptics.dart';
import '../../../core/utils/motion_preferences.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/services/daily_rituals.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'tarot_helpers.dart';

IconData beliefModeIcon(BeliefMode mode) => switch (mode) {
      BeliefMode.unselected => Icons.tune_rounded,
      BeliefMode.westernZodiac => Icons.brightness_5_rounded,
      BeliefMode.tarot => Icons.style_rounded,
      BeliefMode.almanac => Icons.menu_book_rounded,
      BeliefMode.omikuji => Icons.confirmation_number_rounded,
      BeliefMode.runes => Icons.auto_fix_high_rounded,
      BeliefMode.ogham => Icons.park_rounded,
      BeliefMode.justFlower => Icons.spa_rounded,
    };

class ModeRevealInteraction extends StatelessWidget {
  const ModeRevealInteraction({
    super.key,
    required this.mode,
    required this.variantKey,
    required this.variantLabel,
    required this.onReveal,
  });

  final BeliefMode mode;
  final String? variantKey;
  final String variantLabel;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final normalizedVariant = variantLabel.trim();

    final hint = switch (mode) {
      BeliefMode.tarot => l10n.dailyRevealHintFlip,
      BeliefMode.westernZodiac => l10n.dailyRevealHintSlide,
      BeliefMode.almanac => l10n.dailyRevealHintStamp,
      BeliefMode.omikuji => l10n.dailyRevealHintPull,
      BeliefMode.runes => l10n.dailyRevealHintHold,
      BeliefMode.ogham => l10n.dailyRevealHintTrace,
      BeliefMode.justFlower => l10n.dailyRevealHintTap,
      BeliefMode.unselected => l10n.dailyReveal,
    };

    final accent = switch (mode) {
      BeliefMode.tarot => scheme.tertiary,
      BeliefMode.westernZodiac => scheme.primary,
      BeliefMode.almanac => scheme.secondary,
      BeliefMode.omikuji => scheme.tertiary,
      BeliefMode.runes => scheme.primary,
      BeliefMode.ogham => scheme.secondary,
      BeliefMode.justFlower => scheme.primary,
      BeliefMode.unselected => scheme.primary,
    };

    final canShowVariant = mode != BeliefMode.unselected &&
        mode != BeliefMode.justFlower &&
        normalizedVariant.isNotEmpty &&
        normalizedVariant != l10n.profileDailyProfileNotSet &&
        normalizedVariant != l10n.profileDailyProfileNotNeeded &&
        normalizedVariant != l10n.dailyTarotNotDrawn;

    final rune =
        mode == BeliefMode.runes && (variantKey ?? '').trim().isNotEmpty
            ? DailyRituals.runeForId(variantKey!.trim())
            : null;

    Widget interaction() => switch (mode) {
          BeliefMode.tarot => _FlipToReveal(
              accent: accent,
              onReveal: onReveal,
              tarotCardId: variantKey,
            ),
          BeliefMode.westernZodiac => _SlideToReveal(
              accent: accent,
              icon: Icons.brightness_5_rounded,
              onReveal: onReveal,
            ),
          BeliefMode.almanac => _StampToReveal(
              accent: accent,
              icon: Icons.menu_book_rounded,
              sealText: normalizedVariant,
              onReveal: onReveal,
            ),
          BeliefMode.omikuji => _PullToReveal(
              accent: accent,
              topIcon: Icons.confirmation_number_rounded,
              slipIcon: Icons.description_rounded,
              slipLabel: normalizedVariant,
              onReveal: onReveal,
            ),
          BeliefMode.runes => _HoldToReveal(
              accent: accent,
              icon: Icons.auto_fix_high_rounded,
              glyph: rune?.glyph,
              caption: rune?.name,
              onReveal: onReveal,
            ),
          BeliefMode.ogham => _TraceToReveal(
              accent: accent,
              icon: Icons.park_rounded,
              label: normalizedVariant,
              onReveal: onReveal,
            ),
          BeliefMode.justFlower => _TapToReveal(
              accent: accent,
              icon: Icons.spa_rounded,
              onReveal: onReveal,
            ),
          BeliefMode.unselected => _TapToReveal(
              accent: accent,
              icon: Icons.auto_awesome_rounded,
              onReveal: onReveal,
            ),
        };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.dailyReveal,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.70),
              height: 1.25,
            ),
          ),
          if (canShowVariant) ...[
            const SizedBox(height: 10),
            if (mode == BeliefMode.tarot &&
                (variantKey ?? '').trim().isNotEmpty)
              TarotVariantBadge(
                label: normalizedVariant,
                cardId: variantKey!.trim(),
              )
            else
              ModeVariantBadge(
                icon: beliefModeIcon(mode),
                label: normalizedVariant,
              ),
          ],
          const SizedBox(height: 18),
          interaction(),
        ],
      ),
    );
  }
}

class ModeVariantBadge extends StatelessWidget {
  const ModeVariantBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

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
          Icon(
            icon,
            size: 16,
            color: scheme.onSurface.withValues(alpha: 0.78),
          ),
          const SizedBox(width: 8),
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

class _TapToReveal extends StatelessWidget {
  const _TapToReveal({
    required this.accent,
    required this.icon,
    required this.onReveal,
  });

  final Color accent;
  final IconData icon;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = botanicaReduceMotion(context);

    final orb = Semantics(
      button: true,
      label: l10n.dailyReveal,
      child: Tooltip(
        message: l10n.dailyRevealHintTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            onTap: () {
              BotanicaHaptics.primaryPress();
              onReveal();
            },
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.62),
                    scheme.surface.withValues(alpha: 0.32),
                    accent.withValues(alpha: 0.18),
                  ],
                ),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 34,
                  color: scheme.onSurface.withValues(alpha: 0.86),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (reduceMotion) return orb;

    return orb
        .animate(
          onPlay: (controller) =>
              controller.repeat(reverse: true, period: 2200.ms),
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.03, 1.03),
          curve: Curves.easeInOut,
        )
        .fade(begin: 0.96, end: 1.0);
  }
}

class _SlideToReveal extends StatefulWidget {
  const _SlideToReveal({
    required this.accent,
    required this.icon,
    required this.onReveal,
  });

  final Color accent;
  final IconData icon;
  final VoidCallback onReveal;

  @override
  State<_SlideToReveal> createState() => _SlideToRevealState();
}

class _SlideToRevealState extends State<_SlideToReveal>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  bool _completed = false;
  int _tickStage = 0;
  late final AnimationController _recoilController = AnimationController(
    vsync: this,
    duration: BotanicaTokens.motionMedium,
  );
  Animation<double>? _recoil;

  @override
  void initState() {
    super.initState();
    _recoilController.addListener(() {
      final recoil = _recoil;
      if (recoil == null) return;
      setState(() => _progress = recoil.value);
    });
    _recoilController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _recoil = null;
      }
    });
  }

  @override
  void dispose() {
    _recoilController.dispose();
    super.dispose();
  }

  void _stopRecoil() {
    if (_recoilController.isAnimating) {
      _recoilController.stop();
    }
    _recoil = null;
  }

  void _recoilToZero() {
    if (_completed) return;
    if (_progress <= 0.0) {
      setState(() {
        _progress = 0;
        _tickStage = 0;
      });
      return;
    }

    _tickStage = 0;
    _recoil = Tween<double>(begin: _progress, end: 0.0).animate(
      CurvedAnimation(parent: _recoilController, curve: Curves.easeOutCubic),
    );
    _recoilController
      ..value = 0
      ..forward();
  }

  void _setProgress(double value) {
    if (_completed) return;
    final next = value.clamp(0.0, 1.0);
    final stage = (next * 3).floor().clamp(0, 3);
    if (stage > _tickStage && stage < 3) {
      _tickStage = stage;
      BotanicaHaptics.selectionTick();
    }
    setState(() => _progress = next);
    if (_progress >= 0.92) {
      _completed = true;
      BotanicaHaptics.revealClimax();
      widget.onReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final slider = LayoutBuilder(
      builder: (context, constraints) {
        const trackHeight = 56.0;
        const knobSize = 46.0;
        const padding = 6.0;
        final trackWidth = constraints.maxWidth.clamp(240.0, 340.0);
        final knobTravel = trackWidth - (padding * 2) - knobSize;
        final knobLeft = padding + (knobTravel * _progress);
        final fillWidth = (knobLeft + knobSize).clamp(0.0, trackWidth);

        return SizedBox(
          width: trackWidth,
          height: trackHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              _stopRecoil();
              final delta = details.delta.dx / knobTravel;
              _setProgress(_progress + delta);
            },
            onHorizontalDragEnd: (_) {
              if (_completed) return;
              _recoilToZero();
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      BotanicaTokens.radiusPill,
                    ),
                    color: scheme.surface.withValues(alpha: 0.55),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      BotanicaTokens.radiusPill,
                    ),
                    child: AnimatedContainer(
                      duration: BotanicaTokens.motionFast,
                      curve: Curves.easeOutCubic,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            widget.accent.withValues(alpha: 0.55),
                            scheme.surface.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: BotanicaTokens.motionFast,
                  curve: Curves.easeOutCubic,
                  left: knobLeft,
                  top: padding,
                  bottom: padding,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        BotanicaTokens.radiusPill,
                      ),
                      color: scheme.surface.withValues(alpha: 0.78),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.55),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: knobSize,
                      height: knobSize,
                      child: Center(
                        child: Icon(
                          widget.icon,
                          color: scheme.onSurface.withValues(alpha: 0.80),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return Semantics(
      button: true,
      label: l10n.dailyReveal,
      hint: l10n.dailyRevealHintSlide,
      onTap: () {
        _stopRecoil();
        _setProgress(1.0);
      },
      child: Tooltip(
        message: l10n.dailyRevealHintSlide,
        child: slider,
      ),
    );
  }
}

class _HoldToReveal extends StatefulWidget {
  const _HoldToReveal({
    required this.accent,
    required this.icon,
    required this.glyph,
    required this.caption,
    required this.onReveal,
  });

  final Color accent;
  final IconData icon;
  final String? glyph;
  final String? caption;
  final VoidCallback onReveal;

  @override
  State<_HoldToReveal> createState() => _HoldToRevealState();
}

class _HoldToRevealState extends State<_HoldToReveal> {
  double _progress = 0;
  bool _completed = false;
  int _tickStage = 0;
  bool _holding = false;

  void _tick() async {
    while (_holding && !_completed) {
      await Future<void>.delayed(const Duration(milliseconds: 32));
      if (!mounted) return;
      if (!_holding || _completed) break;

      final next = (_progress + 0.025).clamp(0.0, 1.0);
      final stage = (next * 3).floor().clamp(0, 3);
      if (stage > _tickStage && stage < 3) {
        _tickStage = stage;
        BotanicaHaptics.selectionTick();
      }

      setState(() => _progress = next);

      if (_progress >= 1.0) {
        _completed = true;
        BotanicaHaptics.revealClimax();
        widget.onReveal();
        break;
      }
    }
  }

  void _start() {
    if (_completed) return;
    _holding = true;
    _tick();
  }

  void _stop() {
    if (_completed) return;
    _holding = false;
    if (_progress <= 0.05) {
      setState(() {
        _progress = 0;
        _tickStage = 0;
      });
      return;
    }

    setState(() {
      _progress = (_progress * 0.60).clamp(0.0, 1.0);
      _tickStage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final glyph = (widget.glyph ?? '').trim();
    final caption = (widget.caption ?? '').trim();

    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _stop(),
      child: SizedBox(
        width: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 8,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation(
                  widget.accent.withValues(alpha: 0.80),
                ),
              ),
            ),
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accent.withValues(alpha: 0.40),
                    scheme.surface.withValues(alpha: 0.62),
                  ],
                ),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (glyph.isNotEmpty)
                      Text(
                        glyph,
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: scheme.onSurface.withValues(alpha: 0.86),
                        ),
                      )
                    else
                      Icon(
                        widget.icon,
                        size: 30,
                        color: scheme.onSurface.withValues(alpha: 0.82),
                      ),
                    if (caption.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StampToReveal extends StatefulWidget {
  const _StampToReveal({
    required this.accent,
    required this.icon,
    required this.sealText,
    required this.onReveal,
  });

  final Color accent;
  final IconData icon;
  final String sealText;
  final VoidCallback onReveal;

  @override
  State<_StampToReveal> createState() => _StampToRevealState();
}

class _StampToRevealState extends State<_StampToReveal> {
  double _progress = 0;
  bool _completed = false;
  int _tickStage = 0;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_completed) return;
    _pressed = value;
    if (!_pressed) return;

    setState(() {});

    Future<void>.delayed(const Duration(milliseconds: 32), () {
      if (!mounted) return;
      if (_completed) return;
      if (!_pressed) return;

      final next = (_progress + 0.16).clamp(0.0, 1.0);
      final stage = (next * 3).floor().clamp(0, 3);
      if (stage > _tickStage && stage < 3) {
        _tickStage = stage;
        BotanicaHaptics.selectionTick();
      }

      setState(() => _progress = next);

      if (_progress >= 1.0) {
        _completed = true;
        BotanicaHaptics.revealClimax();
        widget.onReveal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: SizedBox(
        width: 220,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 210,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                color: scheme.surface.withValues(alpha: 0.60),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: BotanicaTokens.motionFast,
                  curve: Curves.easeOutCubic,
                  opacity: _progress.clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: -0.06,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusPill),
                        color: widget.accent.withValues(alpha: 0.30),
                        border: Border.all(
                          color: widget.accent.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        widget.sealText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: scheme.onSurface.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: BotanicaTokens.motionFast,
              curve: Curves.easeOutCubic,
              top: _pressed ? 18 : 6,
              child: AnimatedScale(
                duration: BotanicaTokens.motionFast,
                curve: Curves.easeOutCubic,
                scale: _pressed ? 0.96 : 1.0,
                child: Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accent.withValues(alpha: 0.55),
                        scheme.surface.withValues(alpha: 0.40),
                      ],
                    ),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 28,
                      color: scheme.onSurface.withValues(alpha: 0.80),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PullToReveal extends StatefulWidget {
  const _PullToReveal({
    required this.accent,
    required this.topIcon,
    required this.slipIcon,
    required this.slipLabel,
    required this.onReveal,
  });

  final Color accent;
  final IconData topIcon;
  final IconData slipIcon;
  final String slipLabel;
  final VoidCallback onReveal;

  @override
  State<_PullToReveal> createState() => _PullToRevealState();
}

class _PullToRevealState extends State<_PullToReveal> {
  double _progress = 0;
  bool _completed = false;
  int _tickStage = 0;

  void _setProgress(double value) {
    if (_completed) return;
    final next = value.clamp(0.0, 1.0);
    final stage = (next * 3).floor().clamp(0, 3);
    if (stage > _tickStage && stage < 3) {
      _tickStage = stage;
      BotanicaHaptics.selectionTick();
    }
    setState(() => _progress = next);
    if (_progress >= 1.0) {
      _completed = true;
      BotanicaHaptics.revealClimax();
      widget.onReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 240,
      height: 160,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _setProgress(_progress - (details.delta.dy / 120));
        },
        onVerticalDragEnd: (_) {
          if (_completed) return;
          setState(() {
            _progress = 0;
            _tickStage = 0;
          });
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 170,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.accent.withValues(alpha: 0.48),
                      scheme.surface.withValues(alpha: 0.62),
                    ],
                  ),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.topIcon,
                    color: scheme.onSurface.withValues(alpha: 0.80),
                    size: 28,
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: BotanicaTokens.motionFast,
              curve: Curves.easeOutCubic,
              top: 54 + (52 * _progress),
              child: Container(
                width: 190,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                  color: scheme.surface.withValues(alpha: 0.78),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      widget.slipIcon,
                      size: 22,
                      color: scheme.onSurface.withValues(alpha: 0.78),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.slipLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: scheme.onSurface.withValues(alpha: 0.80),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipToReveal extends StatefulWidget {
  const _FlipToReveal({
    required this.accent,
    required this.onReveal,
    required this.tarotCardId,
  });

  final Color accent;
  final VoidCallback onReveal;
  final String? tarotCardId;

  @override
  State<_FlipToReveal> createState() => _FlipToRevealState();
}

class _FlipToRevealState extends State<_FlipToReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BotanicaTokens.motionSlow,
  );
  bool _flipped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _flip() async {
    if (_flipped) return;
    _flipped = true;
    BotanicaHaptics.primaryPress();
    await _controller.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    widget.onReveal();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget back() => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.accent.withValues(alpha: 0.35),
                scheme.surface.withValues(alpha: 0.55),
              ],
            ),
            border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.55)),
          ),
          child: Center(
            child: Icon(
              Icons.style_rounded,
              color: scheme.onSurface.withValues(alpha: 0.78),
              size: 30,
            ),
          ),
        );

    Widget front() {
      final cardId = (widget.tarotCardId ?? '').trim();
      final hasCard = cardId.isNotEmpty;

      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          color: scheme.surface.withValues(alpha: 0.65),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCard)
                Image.asset(
                  tarotAssetForId(cardId),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/placeholders/tarot/unknown.png',
                    fit: BoxFit.cover,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: hasCard
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                          colors: [
                            Colors.transparent,
                            scheme.surface.withValues(alpha: 0.10),
                            scheme.surface.withValues(alpha: 0.55),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.accent.withValues(alpha: 0.22),
                            scheme.surface.withValues(alpha: 0.50),
                          ],
                        ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color:
                      scheme.onSurface.withValues(alpha: hasCard ? 0.68 : 0.78),
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_controller.value);
          final angle = t * pi;
          final showFront = t > 0.5;

          final face = showFront
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: front(),
                )
              : back();

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: SizedBox(
              width: 132,
              height: 180,
              child: face,
            ),
          );
        },
      ),
    );
  }
}

class _TraceToReveal extends StatefulWidget {
  const _TraceToReveal({
    required this.accent,
    required this.icon,
    required this.label,
    required this.onReveal,
  });

  final Color accent;
  final IconData icon;
  final String label;
  final VoidCallback onReveal;

  @override
  State<_TraceToReveal> createState() => _TraceToRevealState();
}

class _TraceToRevealState extends State<_TraceToReveal> {
  final List<Offset> _points = <Offset>[];
  double _distance = 0;
  bool _completed = false;
  int _tickStage = 0;

  void _addPoint(Offset p) {
    if (_completed) return;
    if (_points.isNotEmpty) {
      _distance += (p - _points.last).distance;
    }
    _points.add(p);

    final progress = (_distance / 260).clamp(0.0, 1.0);
    final stage = (progress * 3).floor().clamp(0, 3);
    if (stage > _tickStage && stage < 3) {
      _tickStage = stage;
      BotanicaHaptics.selectionTick();
    }

    setState(() {});

    if (_distance >= 260) {
      _completed = true;
      BotanicaHaptics.revealClimax();
      widget.onReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = widget.label.trim();

    return GestureDetector(
      onPanStart: (d) => _addPoint(d.localPosition),
      onPanUpdate: (d) => _addPoint(d.localPosition),
      onPanEnd: (_) {
        if (_completed) return;
        // Reset after a brief pause to keep the ritual feeling intentional.
        Future<void>.delayed(const Duration(milliseconds: 420), () {
          if (!mounted) return;
          if (_completed) return;
          setState(() {
            _points.clear();
            _distance = 0;
            _tickStage = 0;
          });
        });
      },
      child: SizedBox(
        width: 236,
        height: 132,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
            color: scheme.surface.withValues(alpha: 0.62),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
            child: CustomPaint(
              painter: _TracePainter(
                points: _points,
                strokeColor: widget.accent.withValues(alpha: 0.65),
                guideColor: scheme.outlineVariant.withValues(alpha: 0.45),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                    if (label.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                          color: scheme.onSurface.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  const _TracePainter({
    required this.points,
    required this.strokeColor,
    required this.guideColor,
  });

  final List<Offset> points;
  final Color strokeColor;
  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = guideColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Ogham-like stave guide.
    final x = size.width * 0.50;
    canvas.drawLine(Offset(x, 18), Offset(x, size.height - 18), guidePaint);

    if (points.length < 2) return;

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) {
    return oldDelegate.points.length != points.length ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.guideColor != guideColor;
  }
}
