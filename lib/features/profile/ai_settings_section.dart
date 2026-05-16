import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';
import 'widgets/profile_section_widgets.dart';

class AiSettingsSection extends ConsumerWidget {
  const AiSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BotanicaGlassCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            value: settings.enableAiInsights,
            onChanged: (value) async {
              HapticFeedback.selectionClick();
              final current = ref.read(settingsControllerProvider);
              await ref
                  .read(settingsControllerProvider.notifier)
                  .update(current.copyWith(enableAiInsights: value));
            },
            secondary: const ProfileLeadingCircleIcon(
                icon: Icons.auto_awesome_rounded),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingMd,
              vertical: BotanicaTokens.spacingTiny,
            ),
            title: Text(
              l10n.profileAiInsightsTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              l10n.profileAiInsightsBody,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
            ),
            activeThumbColor: scheme.primary,
          ),
        ),
      ],
    );
  }
}
