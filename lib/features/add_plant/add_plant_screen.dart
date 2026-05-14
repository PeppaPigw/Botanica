import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/plant_idea_search.dart';
import '../../core/i18n/species_search.dart';
import '../../core/widgets/botanica_bottom_action_bar.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_search_field.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/plant_meta.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/services/scheduling.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/photos/photo_storage.dart';
import '../scan/scan_flow_screen.dart';

enum _AddMethod { scan, library, manual }

class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({
    super.key,
    this.initialSpeciesId,
    this.scanFlowOpener,
  });

  static const String subLocation = 'add';

  final String? initialSpeciesId;
  final Future<ScanResult?> Function(BuildContext context)? scanFlowOpener;

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _uuid = const Uuid();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _manualSpeciesController =
      TextEditingController();

  _AddMethod? _method;
  String? _selectedSpeciesId;
  String? _scanImagePath;
  EnvironmentMode _environmentMode = EnvironmentMode.indoor;
  ReminderTimePreference _reminderPref = ReminderTimePreference.morning;
  bool _didSetLocalizedDefaults = false;
  bool _didApplyInitialSpecies = false;

  bool get _hasSpeciesSelection =>
      _selectedSpeciesId != null || (_method == _AddMethod.manual);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);

    if (!_didSetLocalizedDefaults) {
      if (_roomController.text.isEmpty) {
        _roomController.text = l10n.addPlantDefaultRoomLivingRoom;
      }
      if (_manualSpeciesController.text.isEmpty) {
        _manualSpeciesController.text = l10n.addPlantDefaultSpeciesUnknown;
      }
      _didSetLocalizedDefaults = true;
    }

    if (!_didApplyInitialSpecies) {
      _didApplyInitialSpecies = true;
      final initialId = widget.initialSpeciesId?.trim();
      if (initialId != null && initialId.isNotEmpty) {
        final fallbackLocaleCode = Localizations.localeOf(context).languageCode;
        _method = _AddMethod.library;
        _selectedSpeciesId = initialId;

        // Fill a friendly default nickname if none set yet.
        if (_nicknameController.text.trim().isEmpty) {
          () async {
            final localeCode =
                ref.read(settingsControllerProvider).localeCode ??
                    fallbackLocaleCode;

            final species =
                await ref.read(speciesRepositoryProvider).byId(initialId);
            final idea =
                await ref.read(plantIdeaRepositoryProvider).byId(initialId);

            if (!mounted) return;
            if (_nicknameController.text.trim().isNotEmpty) return;

            final label = species?.bestCommonName(localeCode) ??
                idea?.bestCommonName(localeCode);
            if (label == null || label.trim().isEmpty) return;

            setState(() => _nicknameController.text = label);
          }();
        }
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _roomController.dispose();
    _manualSpeciesController.dispose();
    super.dispose();
  }

  Future<void> _selectSpecies(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return;

    setState(() => _selectedSpeciesId = normalized);

    // Auto-fill a friendly nickname only when the user hasn't typed one yet.
    if (_nicknameController.text.trim().isNotEmpty) return;

    final fallbackLocaleCode = Localizations.localeOf(context).languageCode;
    final localeCode =
        ref.read(settingsControllerProvider).localeCode ?? fallbackLocaleCode;

    if (!mounted) return;
    if (_nicknameController.text.trim().isNotEmpty) return;

    final idea = await ref.read(plantIdeaRepositoryProvider).byId(normalized);
    if (!mounted) return;
    if (_nicknameController.text.trim().isNotEmpty) return;
    if (idea != null) {
      _nicknameController.text = idea.bestCommonName(localeCode);
      return;
    }

    final species = await ref.read(speciesRepositoryProvider).byId(normalized);
    if (!mounted) return;
    if (species == null) return;

    if (_nicknameController.text.trim().isNotEmpty) return;
    _nicknameController.text = species.bestCommonName(localeCode);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final nickname = _nicknameController.text.trim().isEmpty
        ? l10n.addPlantTitle
        : _nicknameController.text.trim();

    final plantId = _uuid.v4();
    final now = DateTime.now();

    var plant = Plant(
      id: plantId,
      nickname: nickname,
      speciesId: _method == _AddMethod.manual
          ? _manualSpeciesController.text.trim()
          : (_selectedSpeciesId ?? 'unknown'),
      room: _roomController.text.trim().isEmpty
          ? ''
          : _roomController.text.trim(),
      environmentMode: _environmentMode,
      coverAsset: 'assets/images/placeholder_plant.jpg',
      createdAt: now,
      meta: const PlantMeta(),
    );

    final plantsRepo = ref.read(plantsRepositoryProvider);
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final photosRepo = ref.read(photosRepositoryProvider);
    final speciesRepo = ref.read(speciesRepositoryProvider);
    final ideaRepo = ref.read(plantIdeaRepositoryProvider);
    final env = ref.read(environmentSnapshotProvider);
    final seasonalEngine = ref.read(seasonalCareEngineProvider);
    await ref
        .read(settingsControllerProvider.notifier)
        .setReminderTimePreference(_reminderPref);
    final settings = ref.read(settingsControllerProvider);

    final species = await speciesRepo.byId(plant.speciesId);
    final idea = await ideaRepo.byId(plant.speciesId);
    final defaultCover = (species?.imagePath ?? idea?.imagePath ?? '').trim();
    if (_scanImagePath == null && defaultCover.isNotEmpty) {
      plant = plant.copyWith(coverAsset: defaultCover);
    }
    final waterDecision = seasonalEngine.computeSchedule(
      taskType: TaskType.water,
      now: now,
      environment: env,
      hemisphere: settings.hemisphere,
      environmentMode: plant.environmentMode,
      plantIdea: idea,
      fallbackBaseDays: species?.careDefaults.waterBaseDays,
    );

    final mistDecision = ((idea?.careDefaults.mistBaseDays ?? 0) > 0 ||
            (species?.careDefaults.mistBaseDays ?? 0) > 0)
        ? seasonalEngine.computeSchedule(
            taskType: TaskType.mist,
            now: now,
            environment: env,
            hemisphere: settings.hemisphere,
            environmentMode: plant.environmentMode,
            plantIdea: idea,
            fallbackBaseDays: species?.careDefaults.mistBaseDays,
          )
        : null;

    final fertilizeDecision = seasonalEngine.computeSchedule(
      taskType: TaskType.fertilize,
      now: now,
      environment: env,
      hemisphere: settings.hemisphere,
      environmentMode: plant.environmentMode,
      plantIdea: idea,
      fallbackBaseDays: species?.careDefaults.fertilizeBaseDays,
    );

    final tasks = <TaskInstance>[
      if (waterDecision.dueAt != null)
        TaskInstance(
          id: _uuid.v4(),
          plantId: plantId,
          type: TaskType.water,
          dueAt: _alignToReminderTime(
            waterDecision.dueAt!,
            _reminderPref,
          ),
          status: TaskStatus.pending,
          createdAt: now,
          completedAt: null,
          adjustmentReasonIds: waterDecision.snapshot.reasonIds,
          scheduleSnapshot: waterDecision.snapshot,
        ),
      if (mistDecision?.dueAt != null)
        TaskInstance(
          id: _uuid.v4(),
          plantId: plantId,
          type: TaskType.mist,
          dueAt: _alignToReminderTime(
            mistDecision!.dueAt!,
            _reminderPref,
          ),
          status: TaskStatus.pending,
          createdAt: now,
          completedAt: null,
          adjustmentReasonIds: mistDecision.snapshot.reasonIds,
          scheduleSnapshot: mistDecision.snapshot,
        ),
      if (fertilizeDecision.dueAt != null)
        TaskInstance(
          id: _uuid.v4(),
          plantId: plantId,
          type: TaskType.fertilize,
          dueAt: _alignToReminderTime(
            fertilizeDecision.dueAt!,
            _reminderPref,
          ),
          status: TaskStatus.pending,
          createdAt: now,
          completedAt: null,
          adjustmentReasonIds: fertilizeDecision.snapshot.reasonIds,
          scheduleSnapshot: fertilizeDecision.snapshot,
        ),
    ];

    // If the user scanned a photo, keep it as the initial cover + first journal
    // entry. This makes the Plant Detail hero feel personal immediately.
    final scanPath = _scanImagePath;
    if (scanPath != null && File(scanPath).existsSync()) {
      final entry = await const PhotoStorage().importToJournal(
        file: XFile(scanPath),
        plantId: plantId,
        note: null,
        now: now,
      );
      await photosRepo.add(entry);
      plant = plant.copyWith(coverAsset: entry.filePath);
    }

    await plantsRepo.upsert(plant);
    await tasksRepo.upsertMany(tasks);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.eco_rounded,
                size: BotanicaTokens.iconSizeSm, color: Theme.of(context).colorScheme.inversePrimary),
            BotanicaGaps.hSm,
            Text('${l10n.commonDone}: ${plant.nickname}'),
          ],
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final canSave = _method != null &&
        (_method == _AddMethod.manual || _selectedSpeciesId != null) &&
        _roomController.text.trim().isNotEmpty;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.addPlantTitle),
      ),
      bottomNavigationBar: BotanicaBottomActionBar(
        tier: GlassTier.subtle,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const ValueKey('add-plant-save'),
            onPressed: canSave ? _save : null,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
              ),
            ),
            child: Text(l10n.addPlantSaveButton),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: BotanicaTokens.pagePadding.copyWith(
            bottom: BotanicaBottomActionBar.clearanceFor(context),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            BotanicaSectionLabel(l10n.addPlantTitle),
            const SizedBox(height: BotanicaTokens.spacingSm),
            _MethodGrid(
              selected: _method,
              onSelect: (m) => setState(() {
                _method = m;
                if (m != _AddMethod.scan) {
                  _scanImagePath = null;
                }
                if (m == _AddMethod.manual) {
                  _selectedSpeciesId = null;
                }
              }),
            ),
            const SizedBox(height: BotanicaTokens.spacingRelaxed),
            if (_method == _AddMethod.scan) ...[
              BotanicaGlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.center_focus_strong_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.80)),
                    BotanicaGaps.hSm,
                    Expanded(
                      child: Text(
                        '${l10n.addPlantScanTitle}\n${l10n.addPlantScanBody}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: scheme.onSurface.withValues(alpha: 0.78),
                            ),
                      ),
                    ),
                  ],
                ),
              ).animateSection(index: 0),
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaGlassCard(
                padding: BotanicaTokens.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_scanImagePath != null) ...[
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusL),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(
                            File(_scanImagePath!),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/placeholder_share.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: BotanicaTokens.spacingSm),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: BotanicaButton(
                        variant: BotanicaButtonVariant.outlined,
                        onPressed: () async {
                          final fallbackLocaleCode =
                              Localizations.localeOf(context).languageCode;
                          final result =
                              await (widget.scanFlowOpener?.call(context) ??
                                  ScanFlowScreen.open(context));
                          if (result == null) return;
                          final localeCode =
                              ref.read(settingsControllerProvider).localeCode ??
                                  fallbackLocaleCode;
                          final species = await ref
                              .read(speciesRepositoryProvider)
                              .byId(result.speciesId);
                          final idea = await ref
                              .read(plantIdeaRepositoryProvider)
                              .byId(result.speciesId);
                          if (!mounted) return;
                          setState(() {
                            _selectedSpeciesId = result.speciesId;
                            _scanImagePath = result.imagePath;
                          });
                          if (_nicknameController.text.trim().isEmpty) {
                            final label = species?.bestCommonName(localeCode) ??
                                idea?.bestCommonName(localeCode);
                            if (label != null && label.trim().isNotEmpty) {
                              _nicknameController.text = label;
                            }
                          }
                        },
                        icon: Icons.center_focus_strong_rounded,
                        label: l10n.addPlantScanButton,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_method == _AddMethod.library ||
                _method == _AddMethod.scan) ...[
              const SizedBox(height: BotanicaTokens.spacingXs),
              _SpeciesPicker(
                selectedSpeciesId: _selectedSpeciesId,
                onSelect: _selectSpecies,
              ),
            ],
            if (_method == _AddMethod.manual) ...[
              const SizedBox(height: BotanicaTokens.spacingXs),
              BotanicaSectionLabel(l10n.addPlantManualTitle),
              const SizedBox(height: BotanicaTokens.spacingSm),
              TextField(
                controller: _manualSpeciesController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.addPlantMethodManual,
                  prefixIcon: const Icon(Icons.edit_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: BotanicaTokens.spacingRelaxed),
            if (_method != null && _hasSpeciesSelection) ...[
              BotanicaSectionLabel(l10n.addPlantConfirmTitle),
              const SizedBox(height: BotanicaTokens.spacingSm),
              TextField(
                controller: _nicknameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.addPlantFieldNickname,
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: BotanicaTokens.spacingSm),
              TextField(
                controller: _roomController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.addPlantFieldRoom,
                  prefixIcon: const Icon(Icons.chair_rounded),
                ),
                onChanged: (_) => setState(() {}),
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
              _Segmented<ReminderTimePreference>(
                title: l10n.addPlantReminderTime,
                value: _reminderPref,
                items: [
                  _SegItem(
                    value: ReminderTimePreference.morning,
                    label: l10n.addPlantReminderMorning,
                    icon: Icons.wb_sunny_rounded,
                  ),
                  _SegItem(
                    value: ReminderTimePreference.evening,
                    label: l10n.addPlantReminderEvening,
                    icon: Icons.nights_stay_rounded,
                  ),
                ],
                onChanged: (v) => setState(() => _reminderPref = v),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MethodGrid extends StatelessWidget {
  const _MethodGrid({
    required this.selected,
    required this.onSelect,
  });

  final _AddMethod? selected;
  final ValueChanged<_AddMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _MethodCard(
            selected: selected == _AddMethod.scan,
            icon: Icons.center_focus_strong_rounded,
            title: l10n.addPlantMethodScan,
            tint: scheme.primary,
            onTap: () => onSelect(_AddMethod.scan),
          ),
        ),
        BotanicaGaps.hSm,
        Expanded(
          child: _MethodCard(
            selected: selected == _AddMethod.library,
            icon: Icons.menu_book_rounded,
            title: l10n.addPlantMethodLibrary,
            tint: scheme.tertiary,
            onTap: () => onSelect(_AddMethod.library),
          ),
        ),
        BotanicaGaps.hSm,
        Expanded(
          child: _MethodCard(
            selected: selected == _AddMethod.manual,
            icon: Icons.edit_rounded,
            title: l10n.addPlantMethodManual,
            tint: scheme.secondary,
            onTap: () => onSelect(_AddMethod.manual),
          ),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.tint,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
      child: AnimatedContainer(
        duration: BotanicaTokens.motionFast,
        curve: Curves.easeOut,
        padding: BotanicaTokens.cardPaddingDense,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          color: selected
              ? tint.withValues(alpha: 0.16)
              : scheme.surface.withValues(alpha: 0.75),
          border: Border.all(
            color: selected
                ? tint.withValues(alpha: 0.55)
                : scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: scheme.onSurface.withValues(alpha: 0.85)),
            BotanicaGaps.vXs,
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesPicker extends ConsumerStatefulWidget {
  const _SpeciesPicker({
    required this.selectedSpeciesId,
    required this.onSelect,
  });

  final String? selectedSpeciesId;
  final ValueChanged<String> onSelect;

  @override
  ConsumerState<_SpeciesPicker> createState() => _SpeciesPickerState();
}

class _SpeciesPickerState extends ConsumerState<_SpeciesPicker> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final localeCode = ref.watch(settingsControllerProvider).localeCode ??
        Localizations.localeOf(context).languageCode;
    final ideasAsync = ref.watch(plantIdeaListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addPlantLibraryTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
        ),
        BotanicaGaps.vSm,
        BotanicaSearchField(
          controller: _searchController,
          hintText: l10n.commonSearch,
          onChanged: (_) => setState(() {}),
        ),
        BotanicaGaps.vSm,
        ideasAsync.when(
          data: (ideas) {
            final query = _searchController.text;
            final trimmed = query.trim();
            final normalizedQuery = normalizeSearchText(trimmed);

            bool matchesDetails(PlantIdea idea) {
              if (normalizedQuery.isEmpty) return true;
              final habit = idea.habit(localeCode) ?? '';
              final history = idea.history(localeCode) ?? '';
              return normalizeSearchText(habit).contains(normalizedQuery) ||
                  normalizeSearchText(history).contains(normalizedQuery);
            }

            final filtered = trimmed.isEmpty
                ? ideas
                : ideas
                    .where(
                      (idea) =>
                          plantIdeaMatchesQuery(idea, trimmed) ||
                          matchesDetails(idea),
                    )
                    .toList(growable: false);

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => BotanicaGaps.vSm,
              itemBuilder: (context, index) {
                final idea = filtered[index];
                final selected = idea.plantId == widget.selectedSpeciesId;
                final habit = idea.habit(localeCode);

                return InkWell(
                  key: ValueKey('add-plant-species-${idea.plantId}'),
                  onTap: () => widget.onSelect(idea.plantId),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                  child: AnimatedContainer(
                    duration: BotanicaTokens.motionFast,
                    curve: Curves.easeOut,
                    padding: BotanicaTokens.cardPaddingDense,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusXL),
                      color: selected
                          ? scheme.primaryContainer.withValues(alpha: 0.40)
                          : scheme.surface.withValues(alpha: 0.75),
                      border: Border.all(
                        color: selected
                            ? scheme.primary.withValues(alpha: 0.55)
                            : scheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(BotanicaTokens.radiusL),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                scheme.primaryContainer.withValues(alpha: 0.55),
                                scheme.tertiaryContainer
                                    .withValues(alpha: 0.32),
                              ],
                            ),
                            border: Border.all(
                              color:
                                  scheme.outlineVariant.withValues(alpha: 0.45),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(BotanicaTokens.radiusL),
                            child: idea.imagePath.trim().isNotEmpty &&
                                    !idea.imagePath
                                        .trim()
                                        .contains('unknown.png')
                                ? Image.asset(
                                    idea.imagePath.trim(),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.medium,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.spa_rounded,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.78),
                                    ),
                                  )
                                : Icon(
                                    Icons.spa_rounded,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.78),
                                  ),
                          ),
                        ),
                        BotanicaGaps.hSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                idea.bestCommonName(localeCode),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                              ),
                              BotanicaGaps.vMicro,
                              Text(
                                idea.scientificName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.65),
                                    ),
                              ),
                              if (habit != null && habit.trim().isNotEmpty) ...[
                                BotanicaGaps.vXxs,
                                Text(
                                  habit.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.70),
                                        height: 1.25,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        BotanicaGaps.hSm,
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          error: (_, __) => Padding(
            padding: const EdgeInsets.only(top: 14),
            child: BotanicaStateCard(
              icon: Icons.cloud_off_rounded,
              title: l10n.stateLoadFailedTitle,
              body: l10n.stateLoadFailedBody,
              primaryAction: BotanicaButton(
                variant: BotanicaButtonVariant.outlined,
                onPressed: () {
                  ref.invalidate(plantIdeaMapProvider);
                  ref.invalidate(plantIdeaListProvider);
                },
                icon: Icons.refresh_rounded,
                label: l10n.commonTryAgain,
              ),
            ),
          ),
          loading: () => Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                    scheme.primary.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ),
      ],
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
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
          ),
        ),
        BotanicaGaps.vSm,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final selected = item.value == value;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => onChanged(item.value),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: BotanicaTokens.iconSizeSm),
                  BotanicaGaps.hXxs,
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

DateTime _alignToReminderTime(DateTime date, ReminderTimePreference pref) =>
    alignToReminderTime(date, pref);
