import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';

/// A FAB location that stays aligned with Botanica's centered content width.
///
/// Why:
/// - The bottom navigation pill is constrained to a max width and centered.
/// - On wide screens (tablets), the default `endFloat` FAB sits at the far edge
///   of the screen, which breaks Botanica's "one grid" harmony.
///
/// This location keeps the FAB on the same editorial grid as the nav pill:
/// within the same horizontal insets and max content width.
class BotanicaAlignedEndFabLocation extends FloatingActionButtonLocation {
  const BotanicaAlignedEndFabLocation({
    this.maxContentWidth = BotanicaTokens.maxContentWidth,
    this.horizontalInset = BotanicaTokens.spacingLg,
    this.horizontalPadding = 0,
    this.verticalMargin = BotanicaTokens.spacingLg,
  });

  /// Matches the nav pill max width used in `AppShell`.
  final double maxContentWidth;

  /// Matches Botanica's default page horizontal inset.
  final double horizontalInset;

  /// Optional extra inset from the content edge for the FAB itself.
  final double horizontalPadding;

  /// Vertical margin above the scaffold's content bottom.
  final double verticalMargin;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final scaffoldSize = scaffoldGeometry.scaffoldSize;
    final fabSize = scaffoldGeometry.floatingActionButtonSize;

    final availableWidth =
        math.max(0.0, scaffoldSize.width - (horizontalInset * 2));
    final contentWidth = math.min(availableWidth, maxContentWidth);
    final contentLeft = horizontalInset + (availableWidth - contentWidth) / 2;
    final contentRight = contentLeft + contentWidth;

    final isRtl = scaffoldGeometry.textDirection == TextDirection.rtl;
    final dx = isRtl
        ? contentLeft + horizontalPadding
        : contentRight - fabSize.width - horizontalPadding;

    var dy = scaffoldGeometry.contentBottom - fabSize.height - verticalMargin;

    // Avoid overlapping snackbars.
    final snackHeight = scaffoldGeometry.snackBarSize.height;
    if (snackHeight > 0) {
      dy = math.min(
        dy,
        scaffoldSize.height - snackHeight - fabSize.height - verticalMargin,
      );
    }

    // Avoid overlapping persistent bottom sheets.
    final sheetHeight = scaffoldGeometry.bottomSheetSize.height;
    if (sheetHeight > 0) {
      dy = math.min(
        dy,
        scaffoldGeometry.contentBottom -
            sheetHeight -
            fabSize.height -
            verticalMargin,
      );
    }

    return Offset(dx, dy);
  }
}
