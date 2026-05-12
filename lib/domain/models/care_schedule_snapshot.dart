import 'package:flutter/foundation.dart';

import 'enums.dart';

class CareScheduleSnapshot {
  const CareScheduleSnapshot({
    required this.baseDays,
    required this.seasonalBaseDays,
    required this.adjustedDays,
    required this.season,
    required this.hemisphere,
    required this.environmentMode,
    required this.temperatureC,
    required this.humidityPercent,
    required this.reasonIds,
    required this.seasonalSource,
    required this.computedAt,
  });

  final int baseDays;
  final int seasonalBaseDays;
  final int adjustedDays;
  final Season season;
  final Hemisphere hemisphere;
  final EnvironmentMode environmentMode;
  final double temperatureC;
  final double humidityPercent;
  final List<String> reasonIds;
  final SeasonalSource seasonalSource;
  final DateTime computedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'baseDays': baseDays,
        'seasonalBaseDays': seasonalBaseDays,
        'adjustedDays': adjustedDays,
        'season': season.id,
        'hemisphere': hemisphere.id,
        'environmentMode': environmentMode.id,
        'temperatureC': temperatureC,
        'humidityPercent': humidityPercent,
        'reasonIds': reasonIds,
        'seasonalSource': seasonalSource.id,
        'computedAt': computedAt.toIso8601String(),
      };

  static CareScheduleSnapshot fromJson(Map<String, dynamic> json) =>
      CareScheduleSnapshot(
        baseDays: (json['baseDays'] as num?)?.toInt() ?? 0,
        seasonalBaseDays: (json['seasonalBaseDays'] as num?)?.toInt() ?? 0,
        adjustedDays: (json['adjustedDays'] as num?)?.toInt() ?? 0,
        season: Season.fromId(json['season'] as String?),
        hemisphere: Hemisphere.fromId(json['hemisphere'] as String?),
        environmentMode:
            EnvironmentMode.fromId(json['environmentMode'] as String?),
        temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 20.0,
        humidityPercent: (json['humidityPercent'] as num?)?.toDouble() ?? 50.0,
        reasonIds: (json['reasonIds'] as List?)
                ?.map((e) => e.toString())
                .toList(growable: false) ??
            const <String>[],
        seasonalSource:
            SeasonalSource.fromId(json['seasonalSource'] as String?),
        computedAt: DateTime.tryParse(json['computedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      other is CareScheduleSnapshot &&
      other.baseDays == baseDays &&
      other.seasonalBaseDays == seasonalBaseDays &&
      other.adjustedDays == adjustedDays &&
      other.season == season &&
      other.hemisphere == hemisphere &&
      other.environmentMode == environmentMode &&
      other.temperatureC == temperatureC &&
      other.humidityPercent == humidityPercent &&
      listEquals(other.reasonIds, reasonIds) &&
      other.seasonalSource == seasonalSource &&
      other.computedAt == computedAt;

  @override
  int get hashCode => Object.hash(
        baseDays,
        seasonalBaseDays,
        adjustedDays,
        season,
        hemisphere,
        environmentMode,
        temperatureC,
        humidityPercent,
        Object.hashAll(reasonIds),
        seasonalSource,
        computedAt,
      );
}
