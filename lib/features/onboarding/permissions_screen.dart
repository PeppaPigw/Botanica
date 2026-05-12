import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/permissions/permissions_service.dart';
import '../garden/garden_screen.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  static const String location = '/permissions';

  Future<void> _finish(WidgetRef ref, BuildContext context) async {
    // Read providers up-front so this async flow doesn't touch `ref` after the
    // widget is disposed (integration tests and fast navigation can hit this).
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final environmentController =
        ref.read(environmentControllerProvider.notifier);

    await settingsController.completeOnboarding();
    unawaited(
      environmentController.refresh(force: true),
    );
    if (!context.mounted) return;
    context.go(GardenScreen.location);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final permissionsAsync = ref.watch(permissionsControllerProvider);

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.permissionsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: BotanicaTokens.pagePadding,
          children: [
            Text(
              l10n.permissionsSubtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                height: 1.5,
                letterSpacing: -0.2,
              ),
            ).animateSection(index: 0),
            BotanicaGaps.vBase,
            permissionsAsync.when(
              data: (snapshot) => _NotificationPermissionEducationCard(
                staggerIndex: 1,
                decision: snapshot.notifications,
                onEnable: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .requestNotifications(),
                onOpenSettings: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .openSettings(),
              ),
              error: (_, __) => const _NotificationPermissionEducationCard(
                staggerIndex: 1,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
              loading: () => const _NotificationPermissionEducationCard(
                staggerIndex: 1,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
            ),
            BotanicaGaps.vSm,
            permissionsAsync.when(
              data: (snapshot) => _PermissionCard(
                icon: Icons.location_on_rounded,
                title: l10n.permLocationTitle,
                body: snapshot.location.serviceEnabled
                    ? l10n.permLocationBody
                    : l10n.permLocationServicesOff,
                tint: scheme.tertiary,
                staggerIndex: 2,
                decision: snapshot.location.decision,
                onEnable: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .requestLocation(),
                onOpenSettings: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .openSettings(),
              ),
              error: (_, __) => _PermissionCard(
                icon: Icons.location_on_rounded,
                title: l10n.permLocationTitle,
                body: l10n.permLocationBody,
                tint: scheme.tertiary,
                staggerIndex: 2,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
              loading: () => _PermissionCard(
                icon: Icons.location_on_rounded,
                title: l10n.permLocationTitle,
                body: l10n.permLocationBody,
                tint: scheme.tertiary,
                staggerIndex: 2,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
            ),
            BotanicaGaps.vSm,
            permissionsAsync.when(
              data: (snapshot) => _PermissionCard(
                icon: Icons.camera_alt_rounded,
                title: l10n.permCameraTitle,
                body: l10n.permCameraBody,
                tint: scheme.secondary,
                staggerIndex: 3,
                decision: _combine(snapshot.camera, snapshot.photos),
                onEnable: () async {
                  final controller =
                      ref.read(permissionsControllerProvider.notifier);
                  await controller.requestCamera();
                  await controller.requestPhotos();
                },
                onOpenSettings: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .openSettings(),
              ),
              error: (_, __) => _PermissionCard(
                icon: Icons.camera_alt_rounded,
                title: l10n.permCameraTitle,
                body: l10n.permCameraBody,
                tint: scheme.secondary,
                staggerIndex: 3,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
              loading: () => _PermissionCard(
                icon: Icons.camera_alt_rounded,
                title: l10n.permCameraTitle,
                body: l10n.permCameraBody,
                tint: scheme.secondary,
                staggerIndex: 3,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
            ),
            BotanicaGaps.vMd,
            BotanicaGlassCard(
              padding: BotanicaTokens.cardPadding,
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.78),
                  ),
                  BotanicaGaps.hSm,
                  Expanded(
                    child: Text(
                      l10n.permissionsPrivacyNote,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ).animateSection(index: 4),
            BotanicaGaps.vBase,
            Row(
              children: [
                Expanded(
                  child: BotanicaButton(
                    key: const ValueKey('permissions-not-now'),
                    variant: BotanicaButtonVariant.outlined,
                    onPressed: () => _finish(ref, context),
                    label: l10n.permissionsNotNow,
                  ),
                ),
                BotanicaGaps.hSm,
                Expanded(
                  child: BotanicaButton(
                    key: const ValueKey('permissions-enable-all'),
                    variant: BotanicaButtonVariant.filled,
                    onPressed: () async {
                      final controller =
                          ref.read(permissionsControllerProvider.notifier);
                      await controller.requestNotifications();
                      await controller.requestLocation();
                      await controller.requestCamera();
                      await controller.requestPhotos();
                      if (!context.mounted) return;
                      await _finish(ref, context);
                    },
                    label: l10n.permissionsEnableAll,
                  ),
                ),
              ],
            ).animateSection(index: 5),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.tint,
    required this.staggerIndex,
    required this.decision,
    required this.onEnable,
    required this.onOpenSettings,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color tint;
  final int staggerIndex;
  final AppPermissionDecision? decision;
  final VoidCallback? onEnable;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final resolved = decision;
    final isGranted = resolved == AppPermissionDecision.granted ||
        resolved == AppPermissionDecision.limited ||
        resolved == AppPermissionDecision.provisional;

    final isPermanentlyDenied =
        resolved == AppPermissionDecision.permanentlyDenied;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: 0.16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.50),
              ),
            ),
            child: Icon(
              icon,
              color: scheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
                ),
                BotanicaGaps.vXxs,
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.74),
                    height: 1.4,
                  ),
                ),
                BotanicaGaps.vSm,
                Align(
                  alignment: Alignment.centerLeft,
                  child: BotanicaButton(
                    variant: BotanicaButtonVariant.text,
                    onPressed: isGranted
                        ? null
                        : (isPermanentlyDenied ? onOpenSettings : onEnable),
                    icon: isGranted
                        ? Icons.check_circle_rounded
                        : (isPermanentlyDenied
                            ? Icons.open_in_new_rounded
                            : Icons.lock_open_rounded),
                    label: isGranted
                        ? l10n.permStatusEnabled
                        : (isPermanentlyDenied
                            ? l10n.permActionOpenSettings
                            : l10n.permActionEnable),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animateSection(index: staggerIndex);
  }
}

class _NotificationPermissionEducationCard extends StatelessWidget {
  const _NotificationPermissionEducationCard({
    required this.staggerIndex,
    required this.decision,
    required this.onEnable,
    required this.onOpenSettings,
  });

  final int staggerIndex;
  final AppPermissionDecision? decision;
  final VoidCallback? onEnable;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final resolved = decision;
    final isGranted = resolved == AppPermissionDecision.granted ||
        resolved == AppPermissionDecision.limited ||
        resolved == AppPermissionDecision.provisional;

    final isPermanentlyDenied =
        resolved == AppPermissionDecision.permanentlyDenied;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.50),
                  ),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.82),
                ),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationsSoftAskTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    BotanicaGaps.vXxs,
                    Text(
                      l10n.notificationsSoftAskBody,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Align(
            alignment: Alignment.centerLeft,
            child: BotanicaButton(
              variant: BotanicaButtonVariant.text,
              onPressed: isGranted
                  ? null
                  : (isPermanentlyDenied ? onOpenSettings : onEnable),
              icon: isGranted
                  ? Icons.check_circle_rounded
                  : (isPermanentlyDenied
                      ? Icons.open_in_new_rounded
                      : Icons.lock_open_rounded),
              label: isGranted
                  ? l10n.permStatusEnabled
                  : (isPermanentlyDenied
                      ? l10n.permActionOpenSettings
                      : l10n.permActionEnable),
            ),
          ),
        ],
      ),
    )
        .animateSection(index: staggerIndex);
  }
}

AppPermissionDecision? _combine(
  AppPermissionDecision a,
  AppPermissionDecision b,
) {
  const granted = <AppPermissionDecision>{
    AppPermissionDecision.granted,
    AppPermissionDecision.limited,
    AppPermissionDecision.provisional,
  };

  if (a == AppPermissionDecision.permanentlyDenied ||
      b == AppPermissionDecision.permanentlyDenied) {
    return AppPermissionDecision.permanentlyDenied;
  }

  if (granted.contains(a) && granted.contains(b)) {
    return AppPermissionDecision.granted;
  }

  return AppPermissionDecision.denied;
}
