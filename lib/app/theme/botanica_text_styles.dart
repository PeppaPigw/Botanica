import 'package:flutter/material.dart';

import 'botanica_semantics.dart';

/// Convenience helpers for Botanica semantic typography.
///
/// Botanica already defines its typography in ThemeData (Fraunces for editorial
/// display/headlines; Plus Jakarta Sans for UI). These helpers provide a single
/// place to encode the "semantic" roles from `optimizeUI.md` so screens stop
/// doing ad-hoc `copyWith(fontWeight: …, letterSpacing: …)` everywhere.
class BotanicaTextStyles {
  const BotanicaTextStyles._();

  static TextStyle displayHero(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.displayHero);

  static TextStyle headline(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.headline);

  static TextStyle title(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.title);

  static TextStyle body(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.body);

  static TextStyle bodyMuted(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.bodyMuted);

  static TextStyle label(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.label);

  static TextStyle chip(BuildContext context) =>
      BotanicaSemantics.textStyle(context, BotanicaTextRole.chip);
}

extension BotanicaTextStylesContext on BuildContext {
  TextStyle botanicaText(BotanicaTextRole role) =>
      BotanicaSemantics.textStyle(this, role);

  TextStyle get tsDisplayHero => BotanicaTextStyles.displayHero(this);
  TextStyle get tsHeadline => BotanicaTextStyles.headline(this);
  TextStyle get tsTitle => BotanicaTextStyles.title(this);
  TextStyle get tsBody => BotanicaTextStyles.body(this);
  TextStyle get tsBodyMuted => BotanicaTextStyles.bodyMuted(this);
  TextStyle get tsLabel => BotanicaTextStyles.label(this);
  TextStyle get tsChip => BotanicaTextStyles.chip(this);
}
