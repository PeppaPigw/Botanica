import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const String subLocation = 'credits';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
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
            ).animate().fadeIn(duration: 380.ms),
            const SizedBox(height: 12),
            const BotanicaGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CreditRow(
                    title: 'MDeLuise/plant-it',
                    subtitle: 'Open-source plant tracking + reminders patterns',
                    link: 'https://github.com/MDeLuise/plant-it',
                  ),
                  SizedBox(height: 10),
                  _CreditRow(
                    title: 'SevenSquare-Tech/plant-care-app',
                    subtitle:
                        'Exploration / identification / reminders patterns',
                    link: 'https://github.com/SevenSquare-Tech/plant-care-app',
                  ),
                  SizedBox(height: 10),
                  _CreditRow(
                    title: 'abuanwar072/Plant-App-Flutter-UI',
                    subtitle: 'Polished card layouts + transitions inspiration',
                    link: 'https://github.com/abuanwar072/Plant-App-Flutter-UI',
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
            const SizedBox(height: 16),
            Text(
              l10n.creditsFlutterCommunity,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const BotanicaGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PackageRow(
                      name: 'flutter_riverpod', note: 'State management'),
                  _PackageRow(name: 'go_router', note: 'Navigation'),
                  _PackageRow(
                      name: 'dynamic_color', note: 'Dynamic color schemes'),
                  _PackageRow(name: 'google_fonts', note: 'Typography'),
                  _PackageRow(name: 'flutter_animate', note: 'Micro‑motion'),
                  _PackageRow(
                      name: 'hive / hive_flutter',
                      note: 'Offline-first local DB'),
                  _PackageRow(name: 'flutter_slidable', note: 'Swipe actions'),
                ],
              ),
            ).animate().fadeIn(delay: 160.ms, duration: 420.ms),
            const SizedBox(height: 16),
            Text(
              l10n.creditsUiInspiration,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
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
                  SizedBox(height: 10),
                  _CreditRow(
                    title: 'Planta (iOS)',
                    subtitle: 'Premium details and care explanations',
                    link:
                        'https://www.imore.com/apps/planta-is-a-pricey-but-detailed-houseplant-care-iphone-app-for-indoor-gardeners',
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
            const SizedBox(height: 12),
            Text(
              l10n.creditsPlaceholderNote,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.68),
                height: 1.35,
              ),
            ).animate().fadeIn(delay: 220.ms, duration: 420.ms),
          ],
        ),
      ),
    );
  }
}

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
        const SizedBox(width: 10),
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
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4),
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
          const SizedBox(width: 10),
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
