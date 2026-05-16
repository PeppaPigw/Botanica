import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../utils/motion_preferences.dart';

class BotanicaAnimatedCounter extends StatefulWidget {
  const BotanicaAnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration,
    this.suffix = '',
    this.prefix = '',
  });

  final int value;
  final TextStyle? style;
  final Duration? duration;
  final String suffix;
  final String prefix;

  @override
  State<BotanicaAnimatedCounter> createState() =>
      _BotanicaAnimatedCounterState();
}

class _BotanicaAnimatedCounterState extends State<BotanicaAnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? BotanicaTokens.motionSlow,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  bool _didFirstBuild = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFirstBuild) {
      _didFirstBuild = true;
      if (botanicaReduceMotion(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(covariant BotanicaAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      if (botanicaReduceMotion(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final displayValue = _animation.value.round();
        return Text(
          '${widget.prefix}$displayValue${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
