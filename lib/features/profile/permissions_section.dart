import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/permissions/permissions_service.dart';
import 'widgets/profile_section_widgets.dart';

class PermissionsSection extends ConsumerWidget {
  const PermissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final permissionsAsync = ref.watch(permissionsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(label: l10n.profileSectionPermissions),
        const SizedBox(height: BotanicaTokens.spacingSm),
        permissionsAsync.when(
          data: (snapshot) => BotanicaGlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileTile(
                  icon: Icons.notifications_active_rounded,
                  title: l10n.profileNotifications,
                  subtitle: _permissionSubtitle(l10n, snapshot.notifications),
                  onTap: () => unawaited(
                    _handlePermissionTap(
                      ref,
                      decision: snapshot.notifications,
                      request: () => ref
                          .read(permissionsControllerProvider.notifier)
                          .requestNotifications(),
                    ),
                  ),
                ),
                ProfileDivider(
                    color: scheme.outlineVariant.withValues(alpha: 0.35)),
                ProfileTile(
                  icon: Icons.location_on_rounded,
                  title: l10n.profileLocation,
                  subtitle: snapshot.location.serviceEnabled
                      ? _permissionSubtitle(l10n, snapshot.location.decision)
                      : l10n.permLocationServicesOff,
                  onTap: () => unawaited(
                    _handlePermissionTap(
                      ref,
                      decision: snapshot.location.decision,
                      request: () => ref
                          .read(permissionsControllerProvider.notifier)
                          .requestLocation(),
                    ),
                  ),
                ),
                ProfileDivider(
                    color: scheme.outlineVariant.withValues(alpha: 0.35)),
                ProfileTile(
                  icon: Icons.camera_alt_rounded,
                  title: l10n.permCameraTitle,
                  subtitle: _permissionSubtitle(l10n, snapshot.camera),
                  onTap: () => unawaited(
                    _handlePermissionTap(
                      ref,
                      decision: snapshot.camera,
                      request: () => ref
                          .read(permissionsControllerProvider.notifier)
                          .requestCamera(),
                    ),
                  ),
                ),
                ProfileDivider(
                    color: scheme.outlineVariant.withValues(alpha: 0.35)),
                ProfileTile(
                  icon: Icons.photo_library_rounded,
                  title: l10n.profilePhotos,
                  subtitle: _permissionSubtitle(l10n, snapshot.photos),
                  onTap: () => unawaited(
                    _handlePermissionTap(
                      ref,
                      decision: snapshot.photos,
                      request: () => ref
                          .read(permissionsControllerProvider.notifier)
                          .requestPhotos(),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
          error: (_, __) => BotanicaStateCard(
            icon: Icons.cloud_off_rounded,
            title: l10n.stateLoadFailedTitle,
            body: l10n.stateLoadFailedBody,
            primaryAction: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(permissionsControllerProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.commonTryAgain),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
          loading: () => BotanicaGlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(
                      scheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.commonLoading,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
        ),
      ],
    );
  }
}

String _permissionSubtitle(
    AppLocalizations l10n, AppPermissionDecision decision) {
  return switch (decision) {
    AppPermissionDecision.granted => l10n.permStatusEnabled,
    AppPermissionDecision.limited => l10n.permStatusLimited,
    AppPermissionDecision.provisional => l10n.permStatusProvisional,
    AppPermissionDecision.restricted => l10n.permStatusRestricted,
    AppPermissionDecision.permanentlyDenied => l10n.permStatusBlocked,
    AppPermissionDecision.denied => l10n.permStatusNotEnabled,
  };
}

Future<void> _handlePermissionTap(
  WidgetRef ref, {
  required AppPermissionDecision decision,
  required Future<void> Function() request,
}) async {
  final controller = ref.read(permissionsControllerProvider.notifier);
  if (decision == AppPermissionDecision.permanentlyDenied ||
      decision == AppPermissionDecision.restricted) {
    await controller.openSettings();
    await controller.refresh();
    return;
  }

  await request();
}
