import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/photo_entry.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/photos/photo_storage.dart';

class StorageHealthScreen extends ConsumerStatefulWidget {
  const StorageHealthScreen({super.key});

  static const String subLocation = 'storage';

  @override
  ConsumerState<StorageHealthScreen> createState() =>
      _StorageHealthScreenState();
}

class _StorageHealthScreenState extends ConsumerState<StorageHealthScreen> {
  bool _clearing = false;
  List<PhotoEntry>? _statsPhotos;
  Future<PhotoStorageStats>? _statsFuture;

  Future<void> _clearCache() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    final l10n = AppLocalizations.of(context);

    try {
      await const PhotoStorage().clearTemporaryCache();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.storageCacheCleared),
        ),
      );
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final photosAsync = ref.watch(photoEntriesStreamProvider);
    final diaryAsync = ref.watch(diaryEntriesStreamProvider);

    final loading = photosAsync.isLoading || diaryAsync.isLoading;
    final hasError = photosAsync.hasError || diaryAsync.hasError;

    Widget body;
    if (loading) {
      body = Center(
        child: BotanicaGlassCard(
          padding: BotanicaTokens.cardPaddingDense,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(
                    scheme.primary.withValues(alpha: 0.82),
                  ),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Text(l10n.commonLoading),
            ],
          ),
        ),
      );
    } else if (hasError) {
      body = Center(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: BotanicaStateCard(
            icon: Icons.cloud_off_rounded,
            title: l10n.stateLoadFailedTitle,
            body: l10n.stateLoadFailedBody,
            primaryAction: BotanicaButton(
              variant: BotanicaButtonVariant.outlined,
              icon: Icons.refresh_rounded,
              label: l10n.commonTryAgain,
              onPressed: () {
                ref.invalidate(photoEntriesStreamProvider);
                ref.invalidate(diaryEntriesStreamProvider);
              },
            ),
          ),
        ),
      );
    } else {
      final photos = photosAsync.requireValue;
      final diaryEntries = diaryAsync.requireValue;
      if (!identical(_statsPhotos, photos)) {
        _statsPhotos = photos;
        _statsFuture = const PhotoStorage().statsForEntries(photos);
      }

      body = SafeArea(
        child: ListView(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 26),
          children: [
            FutureBuilder<PhotoStorageStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data;
                final storageLabel = stats == null
                    ? l10n.commonLoading
                    : _formatBytes(stats.totalBytes);
                final fileCount = stats?.existingFiles ?? 0;

                return BotanicaGlassCard(
                  padding: BotanicaTokens.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            color: scheme.primary.withValues(alpha: 0.86),
                          ),
                          const SizedBox(width: BotanicaTokens.spacingSm),
                          Expanded(
                            child: Text(
                              l10n.storageJournalPhotos,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: BotanicaTokens.spacingBase),
                      _MetricRow(
                        label: l10n.storageUsed,
                        value: storageLabel,
                      ),
                      _MetricRow(
                        label: l10n.storagePhotoFiles,
                        value: l10n.storageFileCount(fileCount),
                      ),
                      _MetricRow(
                        label: l10n.storageJournalEntries,
                        value: l10n.storageEntryCount(
                          photos.length + diaryEntries.length,
                        ),
                      ),
                      _MetricRow(
                        label: l10n.storagePhotoEntries,
                        value: l10n.storageEntryCount(photos.length),
                      ),
                      if ((stats?.missingFiles ?? 0) > 0)
                        _MetricRow(
                          label: l10n.storageMissingPhotos,
                          value: l10n.storageFileCount(stats!.missingFiles),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: BotanicaTokens.spacingRelaxed),
            BotanicaGlassCard(
              padding: BotanicaTokens.cardPaddingDense,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.storageCacheTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingXs),
                  Text(
                    l10n.storageCacheBody,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.70),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingBase),
                  SizedBox(
                    width: double.infinity,
                    child: BotanicaButton(
                      variant: BotanicaButtonVariant.outlined,
                      icon: Icons.cleaning_services_rounded,
                      label: _clearing
                          ? l10n.commonLoading
                          : l10n.storageClearCache,
                      onPressed: _clearing ? null : _clearCache,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.storageHealthTitle),
        backgroundColor: Colors.transparent,
      ),
      body: body,
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BotanicaTokens.spacingXxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.70),
              ),
            ),
          ),
          const SizedBox(width: BotanicaTokens.spacingSm),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(gb < 10 ? 1 : 0)} GB';
}
