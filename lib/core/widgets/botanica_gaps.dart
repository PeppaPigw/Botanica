import 'package:flutter/widgets.dart';

import '../../app/theme/botanica_tokens.dart';

/// Reusable spacing widgets to enforce a consistent rhythm and avoid ad-hoc
/// `SizedBox(height: 12)` usage drifting across the codebase.
class BotanicaGap extends StatelessWidget {
  const BotanicaGap.v(this.size, {super.key}) : axis = Axis.vertical;
  const BotanicaGap.h(this.size, {super.key}) : axis = Axis.horizontal;

  final double size;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return axis == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}

class BotanicaGaps {
  const BotanicaGaps._();

  static const BotanicaGap vMicro = BotanicaGap.v(BotanicaTokens.spacingMicro);
  static const BotanicaGap vTiny = BotanicaGap.v(BotanicaTokens.spacingTiny);
  static const BotanicaGap vXxs = BotanicaGap.v(BotanicaTokens.spacingXxs);
  static const BotanicaGap vXs = BotanicaGap.v(BotanicaTokens.spacingXs);
  static const BotanicaGap vSm = BotanicaGap.v(BotanicaTokens.spacingSm);
  static const BotanicaGap vBase = BotanicaGap.v(BotanicaTokens.spacingBase);
  static const BotanicaGap vMd = BotanicaGap.v(BotanicaTokens.spacingMd);
  static const BotanicaGap vLg = BotanicaGap.v(BotanicaTokens.spacingLg);
  static const BotanicaGap vXl = BotanicaGap.v(BotanicaTokens.spacingXl);
  static const BotanicaGap vXxl = BotanicaGap.v(BotanicaTokens.spacingXxl);

  static const BotanicaGap hMicro = BotanicaGap.h(BotanicaTokens.spacingMicro);
  static const BotanicaGap hTiny = BotanicaGap.h(BotanicaTokens.spacingTiny);
  static const BotanicaGap hXxs = BotanicaGap.h(BotanicaTokens.spacingXxs);
  static const BotanicaGap hXs = BotanicaGap.h(BotanicaTokens.spacingXs);
  static const BotanicaGap hSm = BotanicaGap.h(BotanicaTokens.spacingSm);
  static const BotanicaGap hBase = BotanicaGap.h(BotanicaTokens.spacingBase);
  static const BotanicaGap hMd = BotanicaGap.h(BotanicaTokens.spacingMd);
  static const BotanicaGap hLg = BotanicaGap.h(BotanicaTokens.spacingLg);
  static const BotanicaGap hXl = BotanicaGap.h(BotanicaTokens.spacingXl);
  static const BotanicaGap hXxl = BotanicaGap.h(BotanicaTokens.spacingXxl);
}
