import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_bottom_action_bar.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/local_time.dart';
import '../../domain/models/plant.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';

class EditPlantScreen extends ConsumerStatefulWidget {
  const EditPlantScreen({super.key, required this.plantId});

  static const String subLocation = 'edit/:id';

  final String plantId;

  @override
  ConsumerState<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends ConsumerState<EditPlantScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  EnvironmentMode _environmentMode = EnvironmentMode.indoor;
  bool _didInit = false;
  Plant? _plant;
  String? _coverPhotoPath;
  LocalTime? _reminderTimeOverride;

  @override
  void dispose() {
    _nicknameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _initFields(Plant plant) {
    if (_didInit) return;
    _didInit = true;
    _plant = plant;
    _nicknameController.text = plant.nickname;
    _roomController.text = plant.room;
    _environmentMode = plant.environmentMode;
    _coverPhotoPath = plant.coverPhotoPath;
    _reminderTimeOverride = plant.reminderTimeOverride;
  }

  Future<void> _pickCoverPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (picked == null || !mounted) return;

    setState(() => _coverPhotoPath = picked.path);
  }

  Future<void> _save() async {
    final plant = _plant;
    if (plant == null) return;

    final l10n = AppLocalizations.of(context);
    final nickname = _nicknameController.text.trim().isEmpty
        ? plant.nickname
        : _nicknameController.text.trim();
    final room = _roomController.text.trim();

    final updatedPlant = plant.copyWith(
      nickname: nickname,
      room: room,
      environmentMode: _environmentMode,
      coverPhotoPath: _coverPhotoPath,
      reminderTimeOverride: _reminderTimeOverride,
    );

    final plantsRepo = ref.read(plantsRepositoryProvider);
    await CareActions.reschedulePendingTasksIfNeeded(
      oldPlant: plant,
      newPlant: updatedPlant,
      tasksRepository: ref.read(tasksRepositoryProvider),
      speciesRepository: ref.read(speciesRepositoryProvider),
      plantIdeaRepository: ref.read(plantIdeaRepositoryProvider),
      seasonalEngine: ref.read(seasonalCareEngineProvider),
      environment: ref.read(environmentSnapshotProvider),
      settings: ref.read(settingsControllerProvider),
    );

    await plantsRepo.upsert(updatedPlant);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: Theme.of(context).colorScheme.inversePrimary),
            BotanicaGaps.hSm,
            Text('${l10n.commonDone}: ${updatedPlant.nickname}'),
          ],
        ),
      ),
    );
    context.pop();
  }

  Future<void> _archive() async {
    final plant = _plant;
    if (plant == null || plant.isArchived) return;

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.archivePlantTitle(plant.nickname)),
        content: Text(l10n.archivePlantBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.archivePlantConfirm,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final archivedPlant = plant.copyWith(
      nickname: _nicknameController.text.trim().isEmpty
          ? plant.nickname
          : _nicknameController.text.trim(),
      room: _roomController.text.trim(),
      environmentMode: _environmentMode,
      coverPhotoPath: _coverPhotoPath,
      reminderTimeOverride: _reminderTimeOverride,
      isArchived: true,
    );

    final plantsRepo = ref.read(plantsRepositoryProvider);
    await plantsRepo.upsert(archivedPlant);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.archivePlantSuccess(archivedPlant.nickname)),
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () {
            plantsRepo.upsert(archivedPlant.copyWith(isArchived: false));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plantsAsync = ref.watch(plantsStreamProvider);

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.editPlantTitle),
      ),
      bottomNavigationBar: BotanicaBottomActionBar(
        tier: GlassTier.subtle,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
              ),
            ),
            child: Text(l10n.editPlantSaveButton),
          ),
        ),
      ),
      body: plantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => BotanicaStateCard(
          icon: Icons.error_rounded,
          title: l10n.stateLoadFailedTitle,
          body: l10n.stateLoadFailedBody,
        ),
        data: (plants) {
          Plant? plant;
          for (final candidate in plants) {
            if (candidate.id == widget.plantId) {
              plant = candidate;
              break;
            }
          }
          if (plant == null) {
            return BotanicaStateCard(
              icon: Icons.search_off_rounded,
              title: l10n.stateLoadFailedTitle,
              body: l10n.stateLoadFailedBody,
            );
          }

          if (!_didInit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _initFields(plant);
                });
              }
            });
          }

          return SafeArea(
            child: ListView(
              padding: BotanicaTokens.pagePadding.copyWith(
                bottom: BotanicaBottomActionBar.clearanceFor(context),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _CoverPhotoPicker(
                  coverPhotoPath: _coverPhotoPath,
                  fallbackPath: plant.coverAsset,
                  onTap: _pickCoverPhoto,
                ),
                const SizedBox(height: BotanicaTokens.spacingBase),
                BotanicaSectionLabel(l10n.addPlantConfirmTitle),
                const SizedBox(height: BotanicaTokens.spacingSm),
                TextField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.addPlantFieldNickname,
                    prefixIcon: const Icon(Icons.badge_rounded),
                  ),
                ),
                const SizedBox(height: BotanicaTokens.spacingSm),
                TextField(
                  controller: _roomController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.addPlantFieldRoom,
                    prefixIcon: const Icon(Icons.chair_rounded),
                  ),
                ),
                const SizedBox(height: BotanicaTokens.spacingBase),
                _Segmented<EnvironmentMode>(
                  title: l10n.addPlantFieldEnvironment,
                  value: _environmentMode,
                  items: [
                    _SegItem(
                      value: EnvironmentMode.indoor,
                      label: l10n.addPlantEnvIndoor,
                      icon: Icons.home_rounded,
                    ),
                    _SegItem(
                      value: EnvironmentMode.balcony,
                      label: l10n.addPlantEnvBalcony,
                      icon: Icons.balcony_rounded,
                    ),
                    _SegItem(
                      value: EnvironmentMode.outdoor,
                      label: l10n.addPlantEnvOutdoor,
                      icon: Icons.park_rounded,
                    ),
                  ],
                  onChanged: (v) => setState(() => _environmentMode = v),
                ),
                const SizedBox(height: BotanicaTokens.spacingBase),
                _ReminderTimeOverrideField(
                  value: _reminderTimeOverride,
                  onPick: _pickReminderTime,
                  onClear: _reminderTimeOverride == null
                      ? null
                      : () => setState(() => _reminderTimeOverride = null),
                ),
                const SizedBox(height: BotanicaTokens.spacingLg),
                TextButton.icon(
                  onPressed: plant.isArchived ? null : _archive,
                  icon: const Icon(Icons.archive_rounded),
                  label: Text(l10n.plantDetailMenuArchive),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final current = _reminderTimeOverride;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _reminderTimeOverride = LocalTime(
        hour: picked.hour,
        minute: picked.minute,
      );
    });
  }
}

class _ReminderTimeOverrideField extends StatelessWidget {
  const _ReminderTimeOverrideField({
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final LocalTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = value;
    final label = current == null
        ? 'Use global reminder time'
        : MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay(hour: current.hour, minute: current.minute),
          );

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_rounded,
            color: scheme.onSurface.withValues(alpha: 0.78),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addPlantReminderTime,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                BotanicaGaps.vMicro,
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
              tooltip: l10n.commonClear,
            ),
          IconButton.filledTonal(
            onPressed: onPick,
            icon: const Icon(Icons.schedule_rounded),
            tooltip: l10n.addPlantReminderTime,
          ),
        ],
      ),
    );
  }
}

class _CoverPhotoPicker extends StatelessWidget {
  const _CoverPhotoPicker({
    required this.coverPhotoPath,
    required this.fallbackPath,
    required this.onTap,
  });

  final String? coverPhotoPath;
  final String? fallbackPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final path = ((coverPhotoPath ?? '').trim().isNotEmpty
            ? coverPhotoPath
            : fallbackPath)
        ?.trim();

    return BotanicaGlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        child: SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CoverImage(path: path),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      scheme.surface.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: BotanicaTokens.cardPaddingRelaxed,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            scheme.surface.withValues(alpha: 0.82),
                        foregroundColor: scheme.onSurface,
                        child: const Icon(Icons.photo_library_rounded),
                      ),
                      BotanicaGaps.hSm,
                      Expanded(
                        child: Text(
                          l10n.plantDetailAddPhoto,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final normalized = path?.trim() ?? '';

    Widget fallback() => Image.asset(
          'assets/images/placeholder_plant.jpg',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        );

    if (normalized.isEmpty) return fallback();

    if (normalized.startsWith('assets/')) {
      return Image.asset(
        normalized,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    final file = File(normalized);
    if (!file.existsSync()) return fallback();

    return Image.file(
      file,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}

class _SegItem<T> {
  const _SegItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<_SegItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BotanicaSectionLabel(title),
        BotanicaGaps.vSm,
        Row(
          children: items.map((item) {
            final selected = item.value == value;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == items.last ? 0 : BotanicaTokens.spacingXs,
                ),
                child: InkWell(
                  onTap: () => onChanged(item.value),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
                  child: AnimatedContainer(
                    duration: BotanicaTokens.motionFast,
                    padding: BotanicaTokens.cardPaddingDense,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusM),
                      color: selected
                          ? scheme.primaryContainer.withValues(alpha: 0.40)
                          : scheme.surface.withValues(alpha: 0.75),
                      border: Border.all(
                        color: selected
                            ? scheme.primary.withValues(alpha: 0.55)
                            : scheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          item.icon,
                          size: BotanicaTokens.iconSizeMd,
                          color: scheme.onSurface
                              .withValues(alpha: selected ? 0.95 : 0.60),
                        ),
                        BotanicaGaps.vXxs,
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface
                                .withValues(alpha: selected ? 0.95 : 0.60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
