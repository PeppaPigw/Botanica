import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/botanica_tokens.dart';

class BotanicaAiNoteCard extends StatelessWidget {
  const BotanicaAiNoteCard({
    super.key,
    required this.title,
    required this.textToCopy,
    required this.copyTooltip,
    required this.copiedMessage,
    required this.child,
    this.titleStyle,
  });

  final String title;
  final String textToCopy;
  final String copyTooltip;
  final String copiedMessage;
  final Widget child;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> copyNote() async {
      await Clipboard.setData(ClipboardData(text: textToCopy));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.content_copy_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              BotanicaGaps.hSm,
              Text(copiedMessage),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: scheme.onSurface.withValues(alpha: 0.80),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Text(
                title,
                style: titleStyle ??
                    textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ),
            ),
            IconButton(
              tooltip: copyTooltip,
              visualDensity: VisualDensity.compact,
              iconSize: BotanicaTokens.iconSizeMd,
              onPressed: copyNote,
              icon: Icon(
                Icons.content_copy_rounded,
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
        const SizedBox(height: BotanicaTokens.spacingXxs),
        child,
      ],
    );
  }
}
