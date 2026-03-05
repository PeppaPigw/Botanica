import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/services/daily_flower_mode.dart';
import '../../domain/services/zodiac.dart';
import '../../gen/l10n/app_localizations.dart';
import 'widgets/profile_section_widgets.dart';

class DailyProfileSection extends ConsumerWidget {
  const DailyProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(label: l10n.navDaily),
        const SizedBox(height: BotanicaTokens.spacingSm),
        BotanicaGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ProfileTile(
                key: const ValueKey('profile-belief-mode'),
                icon: Icons.auto_awesome_rounded,
                title: l10n.profileBeliefMode,
                subtitle: _beliefLabel(l10n, settings.beliefMode),
                onTap: () => _showBeliefSheet(context, ref),
              ),
              ProfileDivider(
                  color: scheme.outlineVariant.withValues(alpha: 0.35)),
              ProfileTile(
                key: const ValueKey('profile-daily-profile'),
                icon: Icons.badge_rounded,
                title: l10n.profileDailyProfileTitle,
                subtitle: _dailyProfileSubtitle(l10n, settings),
                onTap: () => _showDailyProfileSheet(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _showBeliefSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final current = ref.read(settingsControllerProvider).beliefMode;

  await showBotanicaModalSheet<void>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      final items = <(BeliefMode mode, String label)>[
        (BeliefMode.unselected, l10n.beliefModeNotSet),
        (BeliefMode.tarot, l10n.beliefModeTarot),
        (BeliefMode.westernZodiac, l10n.beliefModeWesternZodiac),
        (BeliefMode.almanac, l10n.beliefModeAlmanac),
        (BeliefMode.omikuji, l10n.beliefModeOmikuji),
        (BeliefMode.runes, l10n.beliefModeRunes),
        (BeliefMode.ogham, l10n.beliefModeOgham),
        (BeliefMode.justFlower, l10n.beliefModeJustFlower),
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
              l10n.profileBeliefMode,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            ...items.map((it) {
              final selected = it.$1 == current;
              return ListTile(
                key: ValueKey('belief-mode-${it.$1.name}'),
                title: Text(it.$2),
                trailing:
                    selected ? const Icon(Icons.check_circle_rounded) : null,
                onTap: () async {
                  final settings = ref.read(settingsControllerProvider);
                  await ref.read(settingsControllerProvider.notifier).update(
                        settings.copyWith(beliefMode: it.$1),
                      );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

Future<void> _showDailyProfileSheet(BuildContext context, WidgetRef ref) async {
  await showBotanicaModalSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    builder: (context) => const _DailyProfileSheet(),
  );
}

class _DailyProfileSheet extends ConsumerStatefulWidget {
  const _DailyProfileSheet();

  @override
  ConsumerState<_DailyProfileSheet> createState() => _DailyProfileSheetState();
}

class _DailyProfileSheetState extends ConsumerState<_DailyProfileSheet> {
  late final TextEditingController _seedController;

  @override
  void initState() {
    super.initState();
    _seedController = TextEditingController(
      text: (ref.read(settingsControllerProvider).dailySeed ?? ''),
    );
  }

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsControllerProvider);
    final mode = settings.beliefMode;
    final modeLabel = _beliefLabel(l10n, mode);

    Future<void> saveDailySeed() async {
      final normalized = _seedController.text.trim();
      final next = normalized.isEmpty ? null : normalized;
      final current = ref.read(settingsControllerProvider);
      await ref.read(settingsControllerProvider.notifier).update(
            current.copyWith(dailySeed: next),
          );
    }

    Future<void> clearDailySeed() async {
      _seedController.clear();
      await saveDailySeed();
    }

    Future<void> pickBirthDate() async {
      final now = DateTime.now();
      final currentBirthDate = settings.birthDate;
      final initial = currentBirthDate ??
          DateTime(now.year - 25, now.month.clamp(1, 12), 1);

      final picked = await showDatePicker(
        context: context,
        initialDate: initial.isAfter(now) ? now : initial,
        firstDate: DateTime(1900, 1, 1),
        lastDate: now,
      );
      if (!context.mounted) return;
      if (picked == null) return;

      final dateOnly = DateTime(picked.year, picked.month, picked.day);
      final current = ref.read(settingsControllerProvider);
      await ref.read(settingsControllerProvider.notifier).update(
            current.copyWith(birthDate: dateOnly),
          );
    }

    Future<void> clearBirthDate() async {
      final current = ref.read(settingsControllerProvider);
      await ref.read(settingsControllerProvider.notifier).update(
            current.copyWith(birthDate: null),
          );
    }

    final westernDerivedId = settings.birthDate == null
        ? null
        : westernZodiacIdForDate(settings.birthDate!);
    final westernDerivedLabel = westernDerivedId == null
        ? null
        : _westernZodiacLabel(l10n, westernDerivedId);

    Widget buildSeedCard() {
      final typed = _seedController.text.trim();
      final current = (settings.dailySeed ?? '').trim();
      final canSave = typed != current;

      return BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.80),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.profileDailySeedTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                if (typed.isNotEmpty)
                  IconButton(
                    tooltip: l10n.commonClear,
                    onPressed: () async {
                      await clearDailySeed();
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.profileDailySeedBody,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.70),
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seedController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.profileDailySeedTitle,
                hintText: l10n.profileDailySeedHint,
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => saveDailySeed(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canSave ? saveDailySeed : null,
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBirthDateCard({
      required String? derivedLabel,
      required VoidCallback? onUseBirthDate,
    }) {
      final birthDate = settings.birthDate;
      final formattedBirthDate = birthDate == null
          ? null
          : MaterialLocalizations.of(context).formatFullDate(birthDate);

      return BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cake_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.80),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.profileBirthdateTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: pickBirthDate,
                  child: Text(
                      birthDate == null ? l10n.commonAdd : l10n.commonEdit),
                ),
                if (birthDate != null)
                  IconButton(
                    tooltip: l10n.commonClear,
                    onPressed: clearBirthDate,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formattedBirthDate ?? l10n.profileBirthdateBody,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.70),
                    height: 1.35,
                  ),
            ),
            if (birthDate != null && derivedLabel != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HintChip(
                    icon: Icons.auto_awesome_rounded,
                    label: derivedLabel,
                  ),
                  if (onUseBirthDate != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(
                        BotanicaTokens.radiusPill,
                      ),
                      onTap: onUseBirthDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            BotanicaTokens.radiusPill,
                          ),
                          color: scheme.primary.withValues(alpha: 0.10),
                          border: Border.all(
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 18,
                              color: scheme.onSurface.withValues(alpha: 0.80),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.profileDailyProfileUseBirthdate,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    Widget buildBody() {
      if (mode == BeliefMode.unselected) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            l10n.profileDailyProfilePickModeFirst,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                  height: 1.4,
                ),
          ),
        );
      }

      Widget modeDetails() => switch (mode) {
            BeliefMode.westernZodiac => Text(
                l10n.dailyInfoModeWesternZodiac,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      height: 1.4,
                    ),
              ),
            BeliefMode.tarot => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileDailyProfileTarotBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/daily');
                      },
                      icon: const Icon(Icons.style_rounded),
                      label: Text(l10n.profileDailyProfileTarotCta),
                    ),
                  ),
                ],
              ),
            BeliefMode.almanac ||
            BeliefMode.omikuji ||
            BeliefMode.runes ||
            BeliefMode.ogham =>
              Text(
                l10n.profileDailyProfileAutoBody(modeLabel),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      height: 1.4,
                    ),
              ),
            BeliefMode.justFlower => Text(
                l10n.dailyInfoModeJustFlower,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      height: 1.4,
                    ),
              ),
            BeliefMode.unselected => const SizedBox.shrink(),
          };

      if (mode == BeliefMode.tarot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            modeDetails(),
          ],
        );
      }

      if (mode == BeliefMode.westernZodiac) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBirthDateCard(
              derivedLabel: westernDerivedLabel,
              onUseBirthDate: settings.birthDate != null &&
                      settings.westernZodiacSignId != null
                  ? () async {
                      final current = ref.read(settingsControllerProvider);
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .update(
                            current.copyWith(
                              westernZodiacSignId: null,
                            ),
                          );
                    }
                  : null,
            ),
            const SizedBox(height: 14),
            _ZodiacPicker(
              title: l10n.beliefModeWesternZodiac,
              currentId: settings.westernZodiacSignId,
              items: _westernZodiacIds,
              labelForId: (id) => _westernZodiacLabel(l10n, id),
              onSelect: (id) async {
                final current = ref.read(settingsControllerProvider);
                await ref.read(settingsControllerProvider.notifier).update(
                      current.copyWith(westernZodiacSignId: id),
                    );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 14),
            modeDetails(),
          ],
        );
      }

      if (mode == BeliefMode.almanac) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSeedCard(),
            const SizedBox(height: 14),
            buildBirthDateCard(
              derivedLabel: null,
              onUseBirthDate: null,
            ),
            const SizedBox(height: 14),
            modeDetails(),
          ],
        );
      }

      final supportsBirthDate = mode == BeliefMode.omikuji ||
          mode == BeliefMode.runes ||
          mode == BeliefMode.ogham ||
          mode == BeliefMode.justFlower;
      if (supportsBirthDate) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSeedCard(),
            const SizedBox(height: 14),
            buildBirthDateCard(
              derivedLabel: westernDerivedLabel,
              onUseBirthDate: null,
            ),
            const SizedBox(height: 14),
            modeDetails(),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSeedCard(),
          const SizedBox(height: 14),
          modeDetails(),
        ],
      );
    }

    return BotanicaSheetBody(
      top: 10,
      bottom: 18,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          Text(
            l10n.profileDailyProfileTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.profileDailyProfileBody(modeLabel),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          buildBody(),
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        color: scheme.surface.withValues(alpha: 0.65),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.onSurface.withValues(alpha: 0.82)),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

String _beliefLabel(AppLocalizations l10n, BeliefMode mode) => switch (mode) {
      BeliefMode.unselected => l10n.beliefModeNotSet,
      BeliefMode.westernZodiac => l10n.beliefModeWesternZodiac,
      BeliefMode.tarot => l10n.beliefModeTarot,
      BeliefMode.almanac => l10n.beliefModeAlmanac,
      BeliefMode.omikuji => l10n.beliefModeOmikuji,
      BeliefMode.runes => l10n.beliefModeRunes,
      BeliefMode.ogham => l10n.beliefModeOgham,
      BeliefMode.justFlower => l10n.beliefModeJustFlower,
    };

String _dailyProfileSubtitle(AppLocalizations l10n, UserSettings settings) {
  final mode = settings.beliefMode;
  if (mode == BeliefMode.unselected) {
    return l10n.profileDailyProfileNotSet;
  }

  if (mode == BeliefMode.tarot) {
    return l10n.profileDailyProfileTarotSubtitle;
  }

  var westernId = settings.westernZodiacSignId;
  if (westernId == null || westernId.trim().isEmpty) {
    final birthDate = settings.birthDate;
    if (birthDate != null) {
      westernId = westernZodiacIdForDate(birthDate);
    }
  }

  if (mode == BeliefMode.westernZodiac) {
    return westernId == null
        ? l10n.profileDailyProfileNotSet
        : _westernZodiacLabel(l10n, westernId);
  }

  final needsPersonalInfo = DailyFlowerMode.needsPersonalInfo(
    beliefMode: mode,
    settings: settings,
  );
  return needsPersonalInfo
      ? l10n.profileDailyProfileNotSet
      : l10n.profileDailyProfileKeySet;
}

const List<String> _westernZodiacIds = <String>[
  'aries',
  'taurus',
  'gemini',
  'cancer',
  'leo',
  'virgo',
  'libra',
  'scorpio',
  'sagittarius',
  'capricorn',
  'aquarius',
  'pisces',
];

String _westernZodiacLabel(AppLocalizations l10n, String id) => switch (id) {
      'aries' => l10n.zodiacAries,
      'taurus' => l10n.zodiacTaurus,
      'gemini' => l10n.zodiacGemini,
      'cancer' => l10n.zodiacCancer,
      'leo' => l10n.zodiacLeo,
      'virgo' => l10n.zodiacVirgo,
      'libra' => l10n.zodiacLibra,
      'scorpio' => l10n.zodiacScorpio,
      'sagittarius' => l10n.zodiacSagittarius,
      'capricorn' => l10n.zodiacCapricorn,
      'aquarius' => l10n.zodiacAquarius,
      'pisces' => l10n.zodiacPisces,
      _ => id,
    };

class _ZodiacPicker extends StatelessWidget {
  const _ZodiacPicker({
    required this.title,
    required this.currentId,
    required this.items,
    required this.labelForId,
    required this.onSelect,
  });

  final String title;
  final String? currentId;
  final List<String> items;
  final String Function(String id) labelForId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((id) {
        final selected = id == currentId;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onSelect(id),
          label: Text(labelForId(id)),
        );
      }).toList(growable: false),
    );
  }
}
