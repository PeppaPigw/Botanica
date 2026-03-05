import 'package:flutter/material.dart';

import '../../app/theme/botanica_semantics.dart';
import 'botanica_gaps.dart';

class BotanicaSection extends StatelessWidget {
  const BotanicaSection({
    super.key,
    required this.children,
    this.title,
    this.trailing,
    this.padding,
  });

  final String? title;
  final Widget? trailing;
  final EdgeInsets? padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? EdgeInsets.zero;

    return Padding(
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: BotanicaSemantics.textStyle(
                      context,
                      BotanicaTextRole.title,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  BotanicaGaps.hSm,
                  trailing!,
                ],
              ],
            ),
            BotanicaGaps.vSm,
          ],
          ...children,
        ],
      ),
    );
  }
}
