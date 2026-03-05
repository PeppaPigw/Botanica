import 'package:flutter/material.dart';

import '../../app/theme/botanica_semantics.dart';
import '../../app/theme/botanica_tokens.dart';

class BotanicaScreenTitle extends StatelessWidget {
  const BotanicaScreenTitle(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines = 1,
  });

  final String text;
  final TextAlign? textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final style = BotanicaSemantics.textStyle(
      context,
      BotanicaTextRole.displayHero,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class BotanicaSectionLabel extends StatelessWidget {
  const BotanicaSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXs),
      child: Text(
        text,
        style: BotanicaSemantics.textStyle(context, BotanicaTextRole.title),
      ),
    );
  }
}
