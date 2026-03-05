import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';

Future<T?> showBotanicaModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = true,
}) {
  final scheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<T>(
    context: context,
    // Botanica uses a global floating navigation pill. Using the root navigator
    // ensures sheets slide over the entire shell (including the nav pill),
    // preventing the pill from appearing to "float in the middle" while a
    // sheet is open.
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: scheme.surface.withValues(alpha: 0.98),
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BotanicaTokens.radiusXL),
      ),
    ),
    builder: builder,
  );
}

/// Standard sheet content padding + SafeArea wrapper.
///
/// Many Botanica sheets use the same editorial padding rhythm. This widget
/// ensures consistent insets and makes it easy to include keyboard clearance
/// when `isScrollControlled: true` sheets include text entry.
class BotanicaSheetBody extends StatelessWidget {
  const BotanicaSheetBody({
    super.key,
    required this.child,
    this.top = 10,
    this.bottom = 18,
    this.includeKeyboardInset = true,
  });

  final Widget child;
  final double top;
  final double bottom;
  final bool includeKeyboardInset;

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        includeKeyboardInset ? MediaQuery.of(context).viewInsets.bottom : 0.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: BotanicaTokens.pagePadding.left,
          right: BotanicaTokens.pagePadding.right,
          top: top,
          bottom: bottom + bottomInset,
        ),
        child: child,
      ),
    );
  }
}
