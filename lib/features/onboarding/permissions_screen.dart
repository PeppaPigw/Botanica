import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
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
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ).animate().fadeIn(duration: 380.ms),
            const SizedBox(height: 18),
            permissionsAsync.when(
              data: (snapshot) => _PermissionCard(
                icon: Icons.notifications_active_rounded,
                title: l10n.permNotificationsTitle,
                body: l10n.permNotificationsBody,
                tint: scheme.primary,
                delayMs: 40,
                decision: snapshot.notifications,
                onEnable: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .requestNotifications(),
                onOpenSettings: () => ref
                    .read(permissionsControllerProvider.notifier)
                    .openSettings(),
              ),
              error: (_, __) => _PermissionCard(
                icon: Icons.notifications_active_rounded,
                title: l10n.permNotificationsTitle,
                body: l10n.permNotificationsBody,
                tint: scheme.primary,
                delayMs: 40,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
              loading: () => _PermissionCard(
                icon: Icons.notifications_active_rounded,
                title: l10n.permNotificationsTitle,
                body: l10n.permNotificationsBody,
                tint: scheme.primary,
                delayMs: 40,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
            ),
            const SizedBox(height: 14),
            permissionsAsync.when(
              data: (snapshot) => _PermissionCard(
                icon: Icons.location_on_rounded,
                title: l10n.permLocationTitle,
                body: snapshot.location.serviceEnabled
                    ? l10n.permLocationBody
                    : l10n.permLocationServicesOff,
                tint: scheme.tertiary,
                delayMs: 90,
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
                delayMs: 90,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
              loading: () => _PermissionCard(
                icon: Icons.location_on_rounded,
                title: l10n.permLocationTitle,
                body: l10n.permLocationBody,
                tint: scheme.tertiary,
                delayMs: 90,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
            ),
            const SizedBox(height: 14),
            permissionsAsync.when(
              data: (snapshot) => _PermissionCard(
                icon: Icons.camera_alt_rounded,
                title: l10n.permCameraTitle,
                body: l10n.permCameraBody,
                tint: scheme.secondary,
                delayMs: 140,
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
                delayMs: 140,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
              loading: () => _PermissionCard(
                icon: Icons.camera_alt_rounded,
                title: l10n.permCameraTitle,
                body: l10n.permCameraBody,
                tint: scheme.secondary,
                delayMs: 140,
                decision: null,
                onEnable: null,
                onOpenSettings: null,
              ),
            ),
            const SizedBox(height: 20),
            BotanicaGlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.78),
                  ),
                  const SizedBox(width: 12),
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
            ).animate().fadeIn(delay: 220.ms, duration: 420.ms),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('permissions-not-now'),
                    onPressed: () => _finish(ref, context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusXL),
                      ),
                    ),
                    child: Text(l10n.permissionsNotNow),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('permissions-enable-all'),
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
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusXL),
                      ),
                    ),
                    child: Text(l10n.permissionsEnableAll),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 260.ms, duration: 420.ms),
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
    required this.delayMs,
    required this.decision,
    required this.onEnable,
    required this.onOpenSettings,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color tint;
  final int delayMs;
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 14),
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
                const SizedBox(height: 6),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.74),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: isGranted
                        ? null
                        : (isPermanentlyDenied ? onOpenSettings : onEnable),
                    icon: Icon(
                      isGranted
                          ? Icons.check_circle_rounded
                          : (isPermanentlyDenied
                              ? Icons.open_in_new_rounded
                              : Icons.lock_open_rounded),
                      size: 18,
                    ),
                    label: Text(
                      isGranted
                          ? l10n.permStatusEnabled
                          : (isPermanentlyDenied
                              ? l10n.permActionOpenSettings
                              : l10n.permActionEnable),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 420.ms)
        .slideY(begin: 0.06, curve: Curves.easeOutCubic);
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
