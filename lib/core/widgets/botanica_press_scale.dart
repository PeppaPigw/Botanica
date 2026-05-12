import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../utils/motion_preferences.dart';

class BotanicaPressScale extends StatefulWidget {
  const BotanicaPressScale({
    super.key,
    required this.child,
    this.scale = 0.98,
  });

  final Widget child;
  final double scale;

  @override
  State<BotanicaPressScale> createState() => _BotanicaPressScaleState();
}

class _BotanicaPressScaleState extends State<BotanicaPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = botanicaReduceMotion(context);

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? widget.scale : 1,
        duration: reduceMotion ? Duration.zero : BotanicaTokens.motionFast,
        curve: BotanicaTokens.curveSettle,
        child: widget.child,
      ),
    );
  }
}
