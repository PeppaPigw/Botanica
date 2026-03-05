import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../gen/l10n/app_localizations.dart';
import 'ai_settings_section.dart';
import 'credits_screen.dart';
import 'daily_profile_section.dart';
import 'permissions_section.dart';
import 'preferences_section.dart';
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
              .animate()
              .fadeIn(duration: 380.ms),
          const SizedBox(height: BotanicaTokens.spacingBase),
          const PreferencesSection(),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const DailyProfileSection(),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const AiSettingsSection(),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const PermissionsSection(),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          ProfileSectionLabel(label: l10n.profileSectionAbout),
          const SizedBox(height: BotanicaTokens.spacingSm),
          BotanicaGlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileTile(
                  icon: Icons.favorite_rounded,
                  title: l10n.profileCredits,
                  subtitle: l10n.creditsOpenSource,
                  onTap: () => context.push(
                    '${ProfileScreen.location}/${CreditsScreen.subLocation}',
                  ),
                ),
                ProfileDivider(
                    color: scheme.outlineVariant.withValues(alpha: 0.35)),
                ProfileTile(
                  icon: Icons.info_rounded,
                  title: l10n.commonAbout,
                  subtitle: l10n.appName,
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 240.ms, duration: 420.ms),
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
