import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/daily_flower.dart';
import '../../domain/models/enums.dart';
import 'ai_exceptions.dart';

@immutable
class DailyAiNoteRequest {
  const DailyAiNoteRequest({
    required this.date,
    required this.localeCode,
    required this.beliefMode,
    required this.variantLabel,
    required this.variantKey,
    required this.content,
  });

  final DateTime date;
  final String localeCode;
  final BeliefMode beliefMode;
  final String variantLabel;
  final String? variantKey;
  final DailyFlowerContent content;

  String get _providerKey {
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return <String>[
      day,
      localeCode.trim().toLowerCase(),
      beliefMode.id,
      (variantKey ?? '').trim().toLowerCase(),
      content.key.trim().toLowerCase(),
    ].join('|');
  }

  @override
  bool operator ==(Object other) =>
      other is DailyAiNoteRequest && other._providerKey == _providerKey;

  @override
  int get hashCode => _providerKey.hashCode;
}

final dailyAiNoteProvider =
    FutureProvider.family<String?, DailyAiNoteRequest>((ref, req) async {
  final settings = ref.watch(settingsControllerProvider);
  if (!settings.enableAiInsights) return null;

  final ai = ref.read(botanicaAiServiceProvider);
  if (!ai.isConfigured) return null;

  try {
    return await ai.generateDailyNote(
      date: req.date,
      localeCode: req.localeCode,
      beliefMode: req.beliefMode,
      variantLabel: req.variantLabel,
      variantKey: req.variantKey,
      content: req.content,
    );
  } on AiException {
    return null;
  }
});

@immutable
class PlantAiInsightRequest {
  const PlantAiInsightRequest({
    required this.date,
    required this.localeCode,
    required this.plantId,
    required this.plantNickname,
    required this.speciesId,
    required this.speciesName,
    required this.scientificName,
    required this.environmentMode,
    required this.tempC,
    required this.humidityPercent,
    required this.nextTasks,
  });

  final DateTime date;
  final String localeCode;
  final String plantId;
  final String plantNickname;
  final String speciesId;
  final String speciesName;
  final String? scientificName;
  final EnvironmentMode environmentMode;
  final double tempC;
  final int humidityPercent;
  final List<String> nextTasks;

  String get _providerKey {
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final tasksSignature = nextTasks
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .take(6)
        .join(',');

    return <String>[
      day,
      localeCode.trim().toLowerCase(),
      plantId.trim().toLowerCase(),
      plantNickname.trim().toLowerCase(),
      speciesId.trim().toLowerCase(),
      environmentMode.id,
      tempC.round().toString(),
      humidityPercent.clamp(0, 100).toString(),
      tasksSignature,
    ].join('|');
  }

  @override
  bool operator ==(Object other) =>
      other is PlantAiInsightRequest && other._providerKey == _providerKey;

  @override
  int get hashCode => _providerKey.hashCode;
}

final plantAiInsightProvider =
    FutureProvider.family<String?, PlantAiInsightRequest>((ref, req) async {
  final settings = ref.watch(settingsControllerProvider);
  if (!settings.enableAiInsights) return null;

  final ai = ref.read(botanicaAiServiceProvider);
  if (!ai.isConfigured) return null;

  try {
    return await ai.generatePlantInsight(
      date: req.date,
      localeCode: req.localeCode,
      plantId: req.plantId,
      plantNickname: req.plantNickname,
      speciesId: req.speciesId,
      speciesName: req.speciesName,
      scientificName: req.scientificName,
      environmentMode: req.environmentMode,
      tempC: req.tempC,
      humidityPercent: req.humidityPercent,
      nextTasks: req.nextTasks,
    );
  } on AiException {
    return null;
  }
});

@immutable
class PlantCareTipRequest {
  const PlantCareTipRequest({
    required this.date,
    required this.localeCode,
    required this.plantId,
    required this.plantNickname,
    required this.speciesId,
    required this.speciesName,
    required this.scientificName,
    required this.environmentMode,
    required this.tempC,
    required this.humidityPercent,
    required this.pendingTasks,
  });

  final DateTime date;
  final String localeCode;
  final String plantId;
  final String plantNickname;
  final String speciesId;
  final String speciesName;
  final String? scientificName;
  final EnvironmentMode environmentMode;
  final double tempC;
  final int humidityPercent;
  final List<String> pendingTasks;

  String get _providerKey {
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final tasksSignature = pendingTasks
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .take(6)
        .join(',');

    return <String>[
      day,
      localeCode.trim().toLowerCase(),
      plantId.trim().toLowerCase(),
      plantNickname.trim().toLowerCase(),
      speciesId.trim().toLowerCase(),
      environmentMode.id,
      tempC.round().toString(),
      humidityPercent.clamp(0, 100).toString(),
      tasksSignature,
    ].join('|');
  }

  @override
  bool operator ==(Object other) =>
      other is PlantCareTipRequest && other._providerKey == _providerKey;

  @override
  int get hashCode => _providerKey.hashCode;
}

final plantCareTipProvider =
    FutureProvider.family<String?, PlantCareTipRequest>((ref, req) async {
  final settings = ref.watch(settingsControllerProvider);
  if (!settings.enableAiInsights) return null;

  final ai = ref.read(botanicaAiServiceProvider);
  if (!ai.isConfigured) return null;

  if (req.pendingTasks.isEmpty) return null;

  try {
    return await ai.generateCareTip(
      date: req.date,
      localeCode: req.localeCode,
      plantId: req.plantId,
      plantNickname: req.plantNickname,
      speciesId: req.speciesId,
      speciesName: req.speciesName,
      scientificName: req.scientificName,
      environmentMode: req.environmentMode,
      tempC: req.tempC,
      humidityPercent: req.humidityPercent,
      pendingTasks: req.pendingTasks,
    );
  } on AiException {
    return null;
  }
});
