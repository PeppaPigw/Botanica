import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const String subLocation = 'credits';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.creditsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 26),
          children: [
            Text(
              l10n.creditsOpenSource,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ).animateSection(index: 0),
            BotanicaGaps.vSm,
            const BotanicaGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CreditRow(
                    title: 'MDeLuise/plant-it',
                    subtitle: 'Open-source plant tracking + reminders patterns',
                    link: 'https://github.com/MDeLuise/plant-it',
                  ),
                  BotanicaGaps.vSm,
                  _CreditRow(
                    title: 'SevenSquare-Tech/plant-care-app',
                    subtitle:
                        'Exploration / identification / reminders patterns',
                    link: 'https://github.com/SevenSquare-Tech/plant-care-app',
                  ),
                  BotanicaGaps.vSm,
                  _CreditRow(
                    title: 'abuanwar072/Plant-App-Flutter-UI',
                    subtitle: 'Polished card layouts + transitions inspiration',
                    link: 'https://github.com/abuanwar072/Plant-App-Flutter-UI',
                  ),
                ],
              ),
            ).animateSection(index: 1),
            BotanicaGaps.vBase,
            Text(
              l10n.creditsFlutterCommunity,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            BotanicaGaps.vSm,
            const BotanicaGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _thirdPartyPackages,
              ),
            ).animateSection(index: 2),
            BotanicaGaps.vBase,
            Text(
              l10n.creditsUiInspiration,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            BotanicaGaps.vSm,
            const BotanicaGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CreditRow(
                    title: 'Dribbble Plant Care UI',
                    subtitle: 'Card-based discovery, clean imagery, spacing',
                    link:
                        'https://dribbble.com/shots/18619889-Plant-Care-App-UI-Design',
                  ),
                  BotanicaGaps.vSm,
                  _CreditRow(
                    title: 'Planta (iOS)',
                    subtitle: 'Premium details and care explanations',
                    link:
                        'https://www.imore.com/apps/planta-is-a-pricey-but-detailed-houseplant-care-iphone-app-for-indoor-gardeners',
                  ),
                ],
              ),
            ).animateSection(index: 3),
          ],
        ),
      ),
    );
  }
}

const _thirdPartyPackages = <_PackageRow>[
  _PackageRow(name: 'cupertino_icons', note: 'MIT'),
  _PackageRow(name: 'intl', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_riverpod', note: 'MIT'),
  _PackageRow(name: 'go_router', note: 'BSD-3-Clause'),
  _PackageRow(name: 'dynamic_color', note: 'Apache-2.0'),
  _PackageRow(name: 'google_fonts', note: 'Apache-2.0'),
  _PackageRow(name: 'flutter_animate', note: 'BSD-3-Clause'),
  _PackageRow(name: 'glassmorphism', note: 'Apache-2.0'),
  _PackageRow(name: 'hive', note: 'Apache-2.0'),
  _PackageRow(name: 'hive_flutter', note: 'Apache-2.0'),
  _PackageRow(name: 'uuid', note: 'MIT'),
  _PackageRow(name: 'collection', note: 'BSD-3-Clause'),
  _PackageRow(name: 'path_provider', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_slidable', note: 'MIT'),
  _PackageRow(name: 'permission_handler', note: 'MIT'),
  _PackageRow(name: 'geolocator', note: 'MIT'),
  _PackageRow(name: 'dio', note: 'MIT'),
  _PackageRow(name: 'characters', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_secure_storage', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_local_notifications', note: 'BSD-3-Clause'),
  _PackageRow(name: 'timezone', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_timezone', note: 'Apache-2.0'),
  _PackageRow(name: 'camera', note: 'BSD-3-Clause'),
  _PackageRow(name: 'image_picker', note: 'BSD-3-Clause'),
  _PackageRow(name: 'path', note: 'BSD-3-Clause'),
  _PackageRow(name: 'crypto', note: 'BSD-3-Clause'),
  _PackageRow(name: 'cross_file', note: 'BSD-3-Clause'),
  _PackageRow(name: 'share_plus', note: 'BSD-3-Clause'),
  _PackageRow(name: 'quick_actions_ios', note: 'BSD-3-Clause'),
  _PackageRow(name: 'quick_actions_android', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_lints', note: 'BSD-3-Clause'),
  _PackageRow(name: 'flutter_launcher_icons', note: 'MIT'),
];

class _CreditRow extends StatelessWidget {
  const _CreditRow({
    required this.title,
    required this.subtitle,
    required this.link,
  });

  final String title;
  final String subtitle;
  final String link;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.link_rounded,
            color: scheme.onSurface.withValues(alpha: 0.70)),
        BotanicaGaps.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              BotanicaGaps.vMicro,
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  height: 1.35,
                ),
              ),
              BotanicaGaps.vTiny,
              Text(
                link,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.primary.withValues(alpha: 0.88),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({
    required this.name,
    required this.note,
  });

  final String name;
  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.code_rounded,
              color: scheme.onSurface.withValues(alpha: 0.70)),
          BotanicaGaps.hSm,
          Expanded(
            child: Text(
              name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            note,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
