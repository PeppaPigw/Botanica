import 'dart:io';

import 'package:botanica/core/haptics/botanica_haptics.dart';
import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_bottom_action_bar.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/diary_entry.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/species.dart';
import '../../domain/services/dryness_index.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';
import '../../services/permissions/permissions_service.dart';
import '../../services/photos/image_compression.dart';
import '../../services/photos/photo_storage.dart';
import '../garden/edit_plant_screen.dart';
import '../garden/garden_screen.dart';
import '../journal/journal_capture_screen.dart';
import 'plant_care_tab.dart';
import 'plant_journal_tab.dart';
import 'plant_logs_tab.dart';
import 'plant_overview_tab.dart';
import 'widgets/plant_detail_pill.dart';

class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({
    super.key,
    required this.plantId,
    this.initialTabIndex = 0,
    this.autoAddPhoto = false,
    this.autoAddNote = false,
  });

  static const String subLocation = 'plant/:id';

  final String plantId;
  final int initialTabIndex;
  final bool autoAddPhoto;
  final bool autoAddNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plantsAsync = ref.watch(plantsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    return plantsAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (_, __) => _ErrorScaffold(
        title: l10n.stateLoadFailedTitle,
        body: l10n.stateLoadFailedBody,
        onRetry: () => ref.invalidate(plantsStreamProvider),
      ),
      data: (plants) {
        Plant? plant;
        for (final p in plants) {
          if (p.id == plantId) {
            plant = p;
            break;
          }
        }

        if (plant == null) {
          return _NotFoundScaffold(
            title: l10n.plantDetailMissingTitle,
            body: l10n.plantDetailMissingBody,
            onBack: () => Navigator.of(context).maybePop(),
            onRetry: () => ref.invalidate(plantsStreamProvider),
          );
        }

        return tasksAsync.when(
          loading: () => _PlantDetailScaffold(
            plant: plant!,
            tasks: const <TaskInstance>[],
            initialTabIndex: initialTabIndex,
            autoAddPhoto: autoAddPhoto,
            autoAddNote: autoAddNote,
          ),
          error: (_, __) => _ErrorScaffold(
            title: l10n.stateLoadFailedTitle,
            body: l10n.stateLoadFailedBody,
            onRetry: () => ref.invalidate(tasksStreamProvider),
            onBack: () => Navigator.of(context).maybePop(),
          ),
          data: (tasks) {
            final plantTasks = tasks
                .where((t) => t.plantId == plant!.id)
                .toList(growable: false)
              ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

            return _PlantDetailScaffold(
              plant: plant!,
              tasks: plantTasks,
              initialTabIndex: initialTabIndex,
              autoAddPhoto: autoAddPhoto,
              autoAddNote: autoAddNote,
            );
          },
        );
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BotanicaPageScaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation(scheme.primary.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({
    required this.title,
    required this.body,
    required this.onRetry,
    this.onBack,
  });

  final String title;
  final String body;
  final VoidCallback onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BotanicaPageScaffold(
      body: Center(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: BotanicaStateCard(
            icon: Icons.cloud_off_rounded,
            title: title,
            body: body,
            primaryAction: BotanicaButton(
              variant: BotanicaButtonVariant.outlined,
              icon: Icons.refresh_rounded,
              label: l10n.commonTryAgain,
              onPressed: onRetry,
            ),
            secondaryAction: onBack == null
                ? null
                : BotanicaButton(
                    onPressed: onBack,
                    variant: BotanicaButtonVariant.text,
                    label: l10n.commonClose,
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotFoundScaffold extends StatelessWidget {
  const _NotFoundScaffold({
    required this.title,
    required this.body,
    required this.onBack,
    required this.onRetry,
  });

  final String title;
  final String body;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BotanicaPageScaffold(
      body: Center(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: BotanicaStateCard(
            icon: Icons.local_florist_rounded,
            title: title,
            body: body,
            primaryAction: BotanicaButton(
              icon: Icons.arrow_back_rounded,
              matchTextDirection: true,
              label: l10n.plantDetailMissingCta,
              onPressed: onBack,
            ),
            secondaryAction: BotanicaButton(
              onPressed: onRetry,
              variant: BotanicaButtonVariant.text,
              label: l10n.commonTryAgain,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantDetailScaffold extends ConsumerStatefulWidget {
  const _PlantDetailScaffold({
    required this.plant,
    required this.tasks,
    required this.initialTabIndex,
    required this.autoAddPhoto,
    required this.autoAddNote,
  });

  final Plant plant;
  final List<TaskInstance> tasks;
  final int initialTabIndex;
  final bool autoAddPhoto;
  final bool autoAddNote;

  @override
  ConsumerState<_PlantDetailScaffold> createState() =>
      _PlantDetailScaffoldState();
}

class _PlantDetailScaffoldState extends ConsumerState<_PlantDetailScaffold> {
  bool _watering = false;
  bool _didRunAutoAction = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_didRunAutoAction) return;
      _didRunAutoAction = true;

      if (widget.autoAddPhoto) {
        _addPhoto();
      } else if (widget.autoAddNote) {
        _addDiaryEntry();
      }
    });
  }

  Future<void> _waterNow() async {
    if (_watering) return;
    setState(() => _watering = true);

    try {
      BotanicaHaptics.primaryPress();

      final now = DateTime.now();
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);
      final speciesRepo = ref.read(speciesRepositoryProvider);
      final ideaRepo = ref.read(plantIdeaRepositoryProvider);
      final env = ref.read(environmentSnapshotProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final settings = ref.read(settingsControllerProvider);

      final pendingWater = widget.tasks
          .where((t) => t.type == TaskType.water && !t.isDismissed)
          .toList(growable: false)
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

      await CareActions.waterNow(
        plant: widget.plant,
        now: now,
        pendingWaterTask: pendingWater.isEmpty ? null : pendingWater.first,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        seasonalEngine: engine,
        environment: env,
        settings: settings,
        updateSettings: (next) =>
            ref.read(settingsControllerProvider.notifier).update(next),
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      BotanicaHaptics.completion();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Text('${l10n.taskTypeWater} · ${l10n.commonDone}'),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _watering = false);
    }
  }

  Future<void> _addPhoto() async {
    final l10n = AppLocalizations.of(context);

    final photosRepo = ref.read(photosRepositoryProvider);
    final plantsRepo = ref.read(plantsRepositoryProvider);
    final permissions = ref.read(permissionsServiceProvider);

    final existing = photosRepo.forPlant(widget.plant.id);
    final ghostPath = existing.isEmpty ? null : existing.first.filePath;

    final source = await showBotanicaModalSheet<ImageSource>(
      context: context,
      useSafeArea: false,
      builder: (context) => BotanicaSheetBody(
        top: 10,
        bottom: 18,
        includeKeyboardInset: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  l10n.journalAddPhotoTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.commonClose,
                ),
              ],
            ),
            BotanicaGaps.vSm,
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.journalAddPhotoCamera),
              subtitle: Text(l10n.journalAddPhotoCameraBody),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.journalAddPhotoGallery),
              subtitle: Text(l10n.journalAddPhotoGalleryBody),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == ImageSource.camera) {
      final decision = await permissions.requestCamera();
      if (!mounted) return;
      if (!_isGranted(decision)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.no_photography_rounded,
                    size: BotanicaTokens.iconSizeSm,
                    color: Theme.of(context).colorScheme.inversePrimary),
                BotanicaGaps.hSm,
                Expanded(child: Text(l10n.journalCameraPermissionNeeded)),
              ],
            ),
          ),
        );
        return;
      }

      final file = await JournalCaptureScreen.capture(
        context,
        title: l10n.journalCaptureTitle,
        ghostOverlayPath: ghostPath,
      );
      if (file == null) return;

      final note = await _promptForNote();
      if (!mounted) return;

      final entry = await const PhotoStorage().importToJournal(
        file: file,
        plantId: widget.plant.id,
        note: note,
      );
      await photosRepo.add(entry);
      await plantsRepo
          .upsert(widget.plant.copyWith(coverAsset: entry.filePath));
    } else {
      final decision = await permissions.requestPhotos();
      if (!mounted) return;
      if (!_isGranted(decision)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.photo_library_rounded,
                    size: BotanicaTokens.iconSizeSm,
                    color: Theme.of(context).colorScheme.inversePrimary),
                BotanicaGaps.hSm,
                Expanded(child: Text(l10n.journalPhotosPermissionNeeded)),
              ],
            ),
          ),
        );
        return;
      }
      if (decision == AppPermissionDecision.limited) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.photo_library_rounded,
                    size: BotanicaTokens.iconSizeSm,
                    color: Theme.of(context).colorScheme.inversePrimary),
                BotanicaGaps.hSm,
                Expanded(child: Text(l10n.journalLimitedPhotosAccess)),
              ],
            ),
          ),
        );
      }

      final picker = ImagePicker();
      const preset = ImageCompressionPresets.journalPhoto;
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: preset.pickerMaxDimension,
        maxHeight: preset.pickerMaxDimension,
        imageQuality: preset.quality,
      );
      if (picked == null) return;

      final note = await _promptForNote();
      if (!mounted) return;

      final entry = await const PhotoStorage().importToJournal(
        file: picked,
        plantId: widget.plant.id,
        note: note,
      );
      await photosRepo.add(entry);
      await plantsRepo
          .upsert(widget.plant.copyWith(coverAsset: entry.filePath));
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.photo_camera_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              BotanicaGaps.hSm,
              Text(l10n.journalPhotoSaved),
            ],
          ),
        ),
    );
  }

  Future<void> _addDiaryEntry() async {
    final l10n = AppLocalizations.of(context);
    final text = await _promptForDiaryText();
    if (text == null) return;

    final now = DateTime.now();
    final entry = DiaryEntry(
      id: const Uuid().v4(),
      plantId: widget.plant.id,
      createdAt: now,
      text: text,
    );

    await ref.read(diaryRepositoryProvider).add(entry);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              BotanicaGaps.hSm,
              Text(l10n.diaryEntrySaved),
            ],
          ),
        ),
    );
  }

  Future<String?> _promptForDiaryText() async {
    final l10n = AppLocalizations.of(context);
    return _promptForTextSheet(
      title: l10n.diaryAddEntryTitle,
      hint: l10n.diaryAddEntryHint,
      icon: Icons.notes_rounded,
      dismissLabel: l10n.commonCancel,
      minLines: 4,
      maxLines: 8,
      prompts: [
        l10n.diaryPromptGrowingWell,
        l10n.diaryPromptNewLeaf,
        l10n.diaryPromptStruggling,
        l10n.diaryPromptRepotted,
        l10n.diaryPromptBlooming,
      ],
    );
  }

  Future<String?> _promptForNote() async {
    final l10n = AppLocalizations.of(context);
    return _promptForTextSheet(
      title: l10n.journalAddNoteTitle,
      hint: l10n.journalAddNoteHint,
      icon: Icons.edit_note_rounded,
      dismissLabel: l10n.commonSkip,
      minLines: 2,
      maxLines: 5,
    );
  }

  Future<String?> _promptForTextSheet({
    required String title,
    required String hint,
    required IconData icon,
    required String dismissLabel,
    required int minLines,
    required int maxLines,
    List<String> prompts = const <String>[],
  }) async {
    return showBotanicaModalSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (_) => _TextPromptSheet(
        title: title,
        hint: hint,
        icon: icon,
        dismissLabel: dismissLabel,
        minLines: minLines,
        maxLines: maxLines,
        prompts: prompts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final env = ref.watch(environmentSnapshotProvider);
    final dryness = DrynessIndex.compute(
      tempC: env.tempC,
      humidityPercent: env.humidity,
    );

    final nextTasks = widget.tasks
        .where((t) => !t.isDismissed)
        .take(4)
        .toList(growable: false);
    final nextWater = widget.tasks
        .where((t) => t.type == TaskType.water && !t.isDismissed)
        .toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final dueInDays = nextWater.isEmpty
        ? null
        : nextWater.first.dueAt.difference(DateTime.now()).inDays;

    final speciesListAsync = ref.watch(speciesListProvider);
    final speciesList = speciesListAsync.when(
      data: (value) => value,
      loading: () => const <Species>[],
      error: (_, __) => const <Species>[],
    );
    Species? species;
    for (final s in speciesList) {
      if (s.id == widget.plant.speciesId) {
        species = s;
        break;
      }
    }

    final heroCoverPath = _resolvePlantCoverPath(
      coverPhotoPath: widget.plant.coverPhotoPath,
      coverAsset: widget.plant.coverAsset,
      speciesImagePath: species?.imagePath,
    );

    final rawCover =
        (widget.plant.coverPhotoPath ?? widget.plant.coverAsset ?? '').trim();
    final hasUserPhotoCover =
        rawCover.isNotEmpty && !rawCover.startsWith('assets/');

    final initialIndex = widget.initialTabIndex.clamp(0, 3);

    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex,
      child: BotanicaPageScaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              stretch: true,
              stretchTriggerOffset: 160,
              onStretchTrigger: _waterNow,
              expandedHeight: 320,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  matchTextDirection: true,
                ),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  onSelected: (action) async {
                    if (action == 'edit') {
                      context.push(
                        '${GardenScreen.location}/${EditPlantScreen.subLocation}'
                            .replaceFirst(':id', widget.plant.id),
                      );
                    } else if (action == 'archive') {
                      final plantsRepo = ref.read(plantsRepositoryProvider);
                      await plantsRepo
                          .upsert(widget.plant.copyWith(isArchived: true));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(l10n
                                  .archivePlantSuccess(widget.plant.nickname))),
                        );
                        context.pop(); // Pop back to garden
                      }
                    } else if (action == 'restore') {
                      final plantsRepo = ref.read(plantsRepositoryProvider);
                      await plantsRepo
                          .upsert(widget.plant.copyWith(isArchived: false));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(l10n
                                  .restorePlantSuccess(widget.plant.nickname))),
                        );
                      }
                    } else if (action == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                              l10n.deletePlantTitle(widget.plant.nickname)),
                          content: Text(l10n.deletePlantBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.commonCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.deletePlantConfirm,
                                  style: TextStyle(
                                      color: Theme.of(ctx).colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final plantsRepo = ref.read(plantsRepositoryProvider);
                        final tasksRepo = ref.read(tasksRepositoryProvider);
                        final logsRepo = ref.read(logsRepositoryProvider);
                        final diariesRepo = ref.read(diaryRepositoryProvider);
                        final photosRepo = ref.read(photosRepositoryProvider);

                        await PlantActions.deletePlantCascade(
                          plantId: widget.plant.id,
                          plantsRepository: plantsRepo,
                          tasksRepository: tasksRepo,
                          logsRepository: logsRepo,
                          photosRepository: photosRepo,
                          diaryRepository: diariesRepo,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.deletePlantSuccess(
                                    widget.plant.nickname))),
                          );
                          context.pop();
                        }
                      }
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(l10n.editPlantTitle),
                      ),
                      if (!widget.plant.isArchived)
                        PopupMenuItem(
                          value: 'archive',
                          child: Text(
                              l10n.archivePlantTitle(widget.plant.nickname)),
                        )
                      else
                        PopupMenuItem(
                          value: 'restore',
                          child: Text(
                              l10n.restorePlantTitle(widget.plant.nickname)),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          l10n.deletePlantTitle(widget.plant.nickname),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
                BotanicaGaps.hXxs,
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.primaryContainer.withValues(alpha: 0.55),
                            scheme.tertiaryContainer.withValues(alpha: 0.25),
                            scheme.surface.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: hasUserPhotoCover ? 0.85 : 0.70,
                      child: Hero(
                        tag: widget.plant.id,
                        child: _CoverImage(path: heroCoverPath),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                          colors: [
                            Colors.transparent,
                            scheme.surface.withValues(alpha: 0.35),
                            scheme.surface.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plant.nickname,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                              ),
                            ).animateSection(index: 0),
                            BotanicaGaps.vXxs,
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                PlantDetailPill(
                                  icon: Icons.water_drop_rounded,
                                  label: dueInDays == null
                                      ? l10n.gardenNoScheduleYet
                                      : l10n.plantDetailNextWateringInDays(
                                          dueInDays.clamp(0, 999)),
                                ),
                                PlantDetailPill(
                                  icon: Icons.opacity_rounded,
                                  label: '${env.humidity}%',
                                ),
                                PlantDetailPill(
                                  icon: Icons.local_florist_rounded,
                                  label: _environmentModeLabel(
                                    l10n,
                                    widget.plant.environmentMode,
                                  ),
                                ),
                              ],
                            ),
                            BotanicaGaps.vSm,
                            Text(
                              _drynessLabel(l10n, dryness),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                              ),
                            ),
                            BotanicaGaps.vXxs,
                            LinearProgressIndicator(
                              value: dryness,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(999),
                              backgroundColor:
                                  scheme.outlineVariant.withValues(alpha: 0.35),
                              valueColor: AlwaysStoppedAnimation(
                                Color.lerp(
                                    scheme.tertiary, scheme.primary, dryness)!,
                              ),
                            ),
                            BotanicaGaps.vSm,
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 120),
                        child: Text(
                          l10n.taskTypeWater,
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: scheme.primary.withValues(alpha: 0.8),
                dividerColor: scheme.outlineVariant.withValues(alpha: 0.35),
                tabs: [
                  Tab(
                    key: const ValueKey('plant-detail-tab-overview'),
                    text: l10n.plantDetailOverview,
                  ),
                  Tab(
                    key: const ValueKey('plant-detail-tab-care'),
                    text: l10n.plantDetailCare,
                  ),
                  Tab(
                    key: const ValueKey('plant-detail-tab-journal'),
                    text: l10n.plantDetailJournal,
                  ),
                  Tab(
                    key: const ValueKey('plant-detail-tab-logs'),
                    text: l10n.plantDetailLogs,
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              PlantOverviewTab(
                plant: widget.plant,
                nextTasks: nextTasks,
              ),
              PlantCareTab(plant: widget.plant, tasks: widget.tasks),
              PlantJournalTab(
                plant: widget.plant,
                onAddPhoto: _addPhoto,
                onAddNote: _addDiaryEntry,
              ),
              PlantLogsTab(plantId: widget.plant.id),
            ],
          ),
        ),
        bottomNavigationBar: BotanicaBottomActionBar(
          tier: GlassTier.subtle,
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _watering ? null : _waterNow,
                  icon: const Icon(Icons.water_drop_rounded),
                  label: Text(l10n.plantDetailWaterNow),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        BotanicaTokens.radiusPill,
                      ),
                    ),
                  ),
                ),
              ),
              BotanicaGaps.hSm,
              IconButton.filledTonal(
                onPressed: _addPhoto,
                icon: const Icon(Icons.photo_camera_rounded),
                tooltip: l10n.plantDetailAddPhoto,
              ),
              BotanicaGaps.hXs,
              IconButton.filledTonal(
                onPressed: _addDiaryEntry,
                icon: const Icon(Icons.edit_note_rounded),
                tooltip: l10n.plantDetailAddNote,
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
    final resolved = (path == null || path!.trim().isEmpty)
        ? 'assets/images/placeholder_plant.jpg'
        : path!.trim();

    if (resolved.startsWith('assets/')) {
      return Image.asset(resolved,
          fit: BoxFit.cover, filterQuality: FilterQuality.high);
    }

    return Image.file(
      File(resolved),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/placeholder_plant.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _TextPromptSheet extends StatefulWidget {
  const _TextPromptSheet({
    required this.title,
    required this.hint,
    required this.icon,
    required this.dismissLabel,
    required this.minLines,
    required this.maxLines,
    this.prompts = const <String>[],
  });

  final String title;
  final String hint;
  final IconData icon;
  final String dismissLabel;
  final int minLines;
  final int maxLines;
  final List<String> prompts;

  @override
  State<_TextPromptSheet> createState() => _TextPromptSheetState();
}

class _TextPromptSheetState extends State<_TextPromptSheet> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prependPrompt(String prompt) {
    final current = _controller.text.trimLeft();
    final prefix = '$prompt: ';
    final next = current.isEmpty
        ? prefix
        : current.startsWith(prefix)
            ? current
            : '$prefix$current';

    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaSheetBody(
      top: BotanicaTokens.spacingSm,
      bottom: BotanicaTokens.spacingLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(widget.icon,
                  color: scheme.onSurface.withValues(alpha: 0.82)),
              BotanicaGaps.hSm,
              Expanded(
                child: Text(
                  widget.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(null),
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.commonClose,
              ),
            ],
          ),
          BotanicaGaps.vSm,
          if (widget.prompts.isNotEmpty) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: BotanicaTokens.spacingXxs,
                runSpacing: BotanicaTokens.spacingXxs,
                children: [
                  for (final prompt in widget.prompts)
                    BotanicaChip(
                      label: prompt,
                      selected: _controller.text.trimLeft().startsWith(prompt),
                      padding: const EdgeInsets.symmetric(
                        horizontal: BotanicaTokens.spacingXs,
                        vertical: BotanicaTokens.spacingTiny,
                      ),
                      textStyle: textTheme.labelSmall,
                      onTap: () => _prependPrompt(prompt),
                    ),
                ],
              ),
            ),
            BotanicaGaps.vSm,
          ],
          BotanicaGlassCard(
            padding: BotanicaTokens.cardPaddingDense,
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(widget.icon),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(widget.dismissLabel),
                ),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final value = _controller.text.trim();
                    Navigator.of(context).pop(value.isEmpty ? null : value);
                  },
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _resolvePlantCoverPath({
  required String? coverPhotoPath,
  required String? coverAsset,
  required String? speciesImagePath,
}) {
  final photo = (coverPhotoPath ?? '').trim();
  final cover = (coverAsset ?? '').trim();
  final species = (speciesImagePath ?? '').trim();

  final isGenericPlaceholder = cover.isEmpty ||
      cover.endsWith('/white.png') ||
      cover.endsWith('white.png') ||
      cover.endsWith('/unknown.png') ||
      cover.endsWith('unknown.png') ||
      cover == 'assets/images/placeholder_plant.jpg';

  if (photo.isNotEmpty) return photo;
  if (!isGenericPlaceholder) return cover;
  if (species.isNotEmpty) return species;
  return 'assets/images/placeholder_plant.jpg';
}

String _drynessLabel(AppLocalizations l10n, double dryness) {
  if (dryness < 0.35) return l10n.plantDetailDrynessLow;
  if (dryness < 0.65) return l10n.plantDetailDrynessBalanced;
  return l10n.plantDetailDrynessHigh;
}

String _environmentModeLabel(AppLocalizations l10n, EnvironmentMode mode) =>
    switch (mode) {
      EnvironmentMode.indoor => l10n.addPlantEnvIndoor,
      EnvironmentMode.balcony => l10n.addPlantEnvBalcony,
      EnvironmentMode.outdoor => l10n.addPlantEnvOutdoor,
    };

bool _isGranted(AppPermissionDecision decision) {
  return decision == AppPermissionDecision.granted ||
      decision == AppPermissionDecision.limited ||
      decision == AppPermissionDecision.provisional;
}
