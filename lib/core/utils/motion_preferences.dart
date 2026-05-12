import 'package:flutter/widgets.dart';

bool botanicaReduceMotion(BuildContext context) {
  final mq = MediaQuery.maybeOf(context);
  if (mq == null) return false;
  return mq.disableAnimations || mq.accessibleNavigation || mq.boldText;
}

extension ReduceMotionAware on Widget {
  Widget animateIfAllowed(
    BuildContext context,
    Widget Function(Widget child) builder,
  ) {
    if (botanicaReduceMotion(context)) return this;
    return builder(this);
  }
}
