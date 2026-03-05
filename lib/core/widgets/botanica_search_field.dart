import 'package:flutter/material.dart';

class BotanicaSearchField extends StatelessWidget {
  const BotanicaSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        // Show the clear affordance whenever there is *any* input, even if it's
        // whitespace-only. The search logic can still trim, but the user should
        // always be able to clear what they typed with one tap.
        final hasText = value.text.isNotEmpty;

        return TextField(
          controller: controller,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: hintText,
            suffixIcon: !hasText
                ? null
                : IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).clearButtonTooltip,
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}
