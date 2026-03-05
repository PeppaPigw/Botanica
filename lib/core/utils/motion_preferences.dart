import 'package:flutter/widgets.dart';

bool botanicaReduceMotion(BuildContext context) {
  final mq = MediaQuery.maybeOf(context);
  if (mq == null) return false;
  return mq.disableAnimations || mq.accessibleNavigation;
}
