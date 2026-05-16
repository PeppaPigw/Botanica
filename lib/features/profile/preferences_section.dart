import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';
import 'widgets/profile_section_widgets.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(label: l10n.profileSectionPreferences),
        const SizedBox(height: BotanicaTokens.spacingSm),
        BotanicaGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ProfileTile(
                icon: Icons.language_rounded,
                title: l10n.profileLanguage,
                subtitle: _languageLabel(l10n, settings.localeCode),
                onTap: () => _showLanguageSheet(context, ref),
              ),
              ProfileDivider(
                  color: scheme.outlineVariant.withValues(alpha: 0.35)),
              ProfileTile(
                icon: Icons.thermostat_rounded,
                title: l10n.profileUnits,
                subtitle: settings.temperatureUnit == TemperatureUnit.celsius
                    ? l10n.unitsCelsius
                    : l10n.unitsFahrenheit,
                onTap: () => _showUnitsSheet(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: BotanicaTokens.spacingBase),
        BotanicaGlassCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            value: settings.enableDynamicColor,
            onChanged: (value) async {
              HapticFeedback.selectionClick();
              final current = ref.read(settingsControllerProvider);
              await ref
                  .read(settingsControllerProvider.notifier)
                  .update(current.copyWith(enableDynamicColor: value));
            },
            secondary:
                const ProfileLeadingCircleIcon(icon: Icons.palette_rounded),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingMd,
              vertical: BotanicaTokens.spacingTiny,
            ),
            title: Text(
              l10n.profileDynamicColorTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              l10n.profileDynamicColorBody,
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
        const SizedBox(height: BotanicaTokens.spacingBase),
        BotanicaGlassCard(
          padding: EdgeInsets.zero,
          child: ProfileTile(
            icon: Icons.beach_access_rounded,
            title: l10n.vacationModeTitle,
            subtitle: settings.isOnVacation
                ? l10n.vacationModeActiveUntil(
                    MaterialLocalizations.of(context)
                        .formatShortDate(settings.vacationEndDate!),
                  )
                : l10n.vacationModeOff,
            onTap: () => _showVacationSheet(context, ref),
          ),
        ),
      ],
    );
  }
}

String _languageLabel(AppLocalizations l10n, String? localeCode) =>
    switch (localeCode) {
      null => l10n.profileLanguageSystem,
      'en' => 'English',
      'zh' => '中文',
      'es' => 'Español',
      'ar' => 'العربية',
      _ => localeCode,
    };

Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final current = ref.read(settingsControllerProvider).localeCode;

  await showBotanicaModalSheet<void>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      final items = <(String? code, String label)>[
        (null, l10n.profileLanguageSystem),
        ('en', 'English'),
        ('zh', '中文'),
        ('es', 'Español'),
        ('ar', 'العربية'),
      ];
      return BotanicaSheetBody(
        top: 10,
        bottom: 18,
        includeKeyboardInset: false,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Text(
              l10n.profileLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            BotanicaGaps.vSm,
            BotanicaGlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final it = entry.value;
                    final selected = it.$1 == current;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(it.$2),
                          trailing: selected
                              ? Icon(Icons.check_circle_rounded,
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLocaleCode(it.$1);
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                        ),
                        if (index < items.length - 1)
                          ProfileDivider(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.35),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showUnitsSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final current = ref.read(settingsControllerProvider).temperatureUnit;

  await showBotanicaModalSheet<void>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      final items = <(TemperatureUnit unit, String label)>[
        (TemperatureUnit.celsius, l10n.unitsCelsius),
        (TemperatureUnit.fahrenheit, l10n.unitsFahrenheit),
      ];
      return BotanicaSheetBody(
        top: 10,
        bottom: 18,
        includeKeyboardInset: false,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Text(
              l10n.profileUnits,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            BotanicaGaps.vSm,
            BotanicaGlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final it = entry.value;
                    final selected = it.$1 == current;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(it.$2),
                          trailing: selected
                              ? Icon(Icons.check_circle_rounded,
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                          onTap: () async {
                            final settings =
                                ref.read(settingsControllerProvider);
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .update(
                                  settings.copyWith(temperatureUnit: it.$1),
                                );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                        ),
                        if (index < items.length - 1)
                          ProfileDivider(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.35),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showVacationSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final settings = ref.read(settingsControllerProvider);

  if (settings.isOnVacation) {
    final cancel = await showBotanicaModalSheet<bool>(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return BotanicaSheetBody(
          top: 10,
          bottom: 18,
          includeKeyboardInset: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.vacationModeTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              BotanicaGaps.vSm,
              Text(
                l10n.vacationModeActiveUntil(
                  MaterialLocalizations.of(context)
                      .formatShortDate(settings.vacationEndDate!),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              BotanicaGaps.vMd,
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.vacationModeEnd),
              ),
            ],
          ),
        );
      },
    );
    if (cancel == true) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setVacationEnd(null);
    }
    return;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final picked = await showDatePicker(
    context: context,
    initialDate: today.add(const Duration(days: 7)),
    firstDate: today.add(const Duration(days: 1)),
    lastDate: today.add(const Duration(days: 90)),
    helpText: l10n.vacationModePickDate,
  );

  if (picked != null) {
    await ref
        .read(settingsControllerProvider.notifier)
        .setVacationEnd(picked);
  }
}
