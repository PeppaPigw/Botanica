import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../gen/l10n/app_localizations.dart';
import 'ai_settings_section.dart';
import 'credits_screen.dart';
import 'daily_profile_section.dart';
import 'garden_wellness_screen.dart';
import 'permissions_section.dart';
import 'preferences_section.dart';
import 'storage_health_screen.dart';
import 'widgets/profile_section_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String location = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: BotanicaTokens.pagePaddingWithBottomNav(context),
        children: [
          BotanicaScreenTitle(l10n.navProfile)
              .animateSection(index: 0),
          const SizedBox(height: BotanicaTokens.spacingBase),
          const PreferencesSection().animateSection(index: 1),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const DailyProfileSection().animateSection(index: 2),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const AiSettingsSection().animateSection(index: 3),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const PermissionsSection().animateSection(index: 4),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSectionLabel(label: l10n.profileSectionData),
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaGlassCard(
                padding: EdgeInsets.zero,
                child: ProfileTile(
                  icon: Icons.storage_rounded,
                  title: l10n.storageHealthTitle,
                  subtitle: l10n.storageHealthSubtitle,
                  onTap: () => context.push(
                    '${ProfileScreen.location}/${StorageHealthScreen.subLocation}',
                  ),
                ),
              ),
            ],
          ).animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSectionLabel(label: l10n.profileSectionAbout),
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaGlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileTile(
                      icon: Icons.monitor_heart_rounded,
                      title: l10n.gardenWellnessTitle,
                      subtitle: l10n.gardenWellnessSubtitle,
                      onTap: () => context.push(
                        '${ProfileScreen.location}/${GardenWellnessScreen.subLocation}',
                      ),
                    ),
                    ProfileDivider(
                        color:
                            scheme.outlineVariant.withValues(alpha: 0.35)),
                    ProfileTile(
                      icon: Icons.favorite_rounded,
                      title: l10n.profileCredits,
                      subtitle: l10n.creditsOpenSource,
                      onTap: () => context.push(
                        '${ProfileScreen.location}/${CreditsScreen.subLocation}',
                      ),
                    ),
                    ProfileDivider(
                        color:
                            scheme.outlineVariant.withValues(alpha: 0.35)),
                    ProfileTile(
                      icon: Icons.info_rounded,
                      title: l10n.commonAbout,
                      subtitle: l10n.appName,
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
              ),
            ],
          ).animateSection(index: 6),
        ],
      ),
    );
  }
}

void _showAbout(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showAboutDialog(
    context: context,
    applicationName: l10n.appName,
    applicationVersion: '1.0.0',
    applicationIcon: Icon(
      Icons.local_florist_rounded,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    ),
    children: [
      Text(
        l10n.appTagline,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}
