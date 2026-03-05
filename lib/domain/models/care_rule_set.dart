import 'collection_utils.dart';
import 'enums.dart';
import 'time_codec.dart';

class CareRuleEnvironmentProfile {
  final bool humidityEnabled;
  final bool temperatureEnabled;
  final bool seasonEnabled;

  /// If `humidityPercent` is below this threshold, the interval is multiplied by
  /// [humidityLowMultiplier].
  final double humidityLowThresholdPercent;
  final double humidityLowMultiplier;

  /// If `humidityPercent` is above this threshold, the interval is multiplied by
  /// [humidityHighMultiplier].
  final double humidityHighThresholdPercent;
  final double humidityHighMultiplier;

  /// If `temperatureC` is above this threshold, the interval is multiplied by
  /// [temperatureHotMultiplier].
  final double temperatureHotThresholdC;
  final double temperatureHotMultiplier;

  /// If `temperatureC` is below this threshold, the interval is multiplied by
  /// [temperatureColdMultiplier].
  final double temperatureColdThresholdC;
  final double temperatureColdMultiplier;

  /// Per-season multipliers (e.g., winter: 1.2) applied before exposure
  /// weighting.
  final Map<Season, double> seasonMultipliers;

  const CareRuleEnvironmentProfile({
    required this.humidityEnabled,
    required this.temperatureEnabled,
    required this.seasonEnabled,
    required this.humidityLowThresholdPercent,
    required this.humidityLowMultiplier,
    required this.humidityHighThresholdPercent,
    required this.humidityHighMultiplier,
    required this.temperatureHotThresholdC,
    required this.temperatureHotMultiplier,
    required this.temperatureColdThresholdC,
    required this.temperatureColdMultiplier,
    required this.seasonMultipliers,
  });

  factory CareRuleEnvironmentProfile.defaultsFor(TaskType type) {
    switch (type) {
      case TaskType.water:
        return const CareRuleEnvironmentProfile(
          humidityEnabled: true,
          temperatureEnabled: true,
          seasonEnabled: true,
          humidityLowThresholdPercent: 35,
          humidityLowMultiplier: 0.75,
          humidityHighThresholdPercent: 70,
          humidityHighMultiplier: 1.15,
          temperatureHotThresholdC: 28,
          temperatureHotMultiplier: 0.85,
          temperatureColdThresholdC: 15,
          temperatureColdMultiplier: 1.15,
          seasonMultipliers: {Season.winter: 1.20},
        );
      case TaskType.mist:
        return const CareRuleEnvironmentProfile(
          humidityEnabled: true,
          temperatureEnabled: false,
          seasonEnabled: false,
          humidityLowThresholdPercent: 40,
          humidityLowMultiplier: 0.70,
          humidityHighThresholdPercent: 70,
          humidityHighMultiplier: 1.20,
          temperatureHotThresholdC: 28,
          temperatureHotMultiplier: 1.0,
          temperatureColdThresholdC: 15,
          temperatureColdMultiplier: 1.0,
          seasonMultipliers: {},
        );
      case TaskType.fertilize:
        return const CareRuleEnvironmentProfile(
          humidityEnabled: false,
          temperatureEnabled: false,
          seasonEnabled: true,
          humidityLowThresholdPercent: 35,
          humidityLowMultiplier: 1.0,
          humidityHighThresholdPercent: 70,
          humidityHighMultiplier: 1.0,
          temperatureHotThresholdC: 28,
          temperatureHotMultiplier: 1.0,
          temperatureColdThresholdC: 15,
          temperatureColdMultiplier: 1.0,
          seasonMultipliers: {Season.winter: 1.35},
        );
      case TaskType.rotate:
      case TaskType.prune:
      case TaskType.repot:
      case TaskType.checkPests:
      case TaskType.wipeLeaves:
      case TaskType.sunlightAdjustment:
        return const CareRuleEnvironmentProfile(
          humidityEnabled: false,
          temperatureEnabled: false,
          seasonEnabled: false,
          humidityLowThresholdPercent: 35,
          humidityLowMultiplier: 1.0,
          humidityHighThresholdPercent: 70,
          humidityHighMultiplier: 1.0,
          temperatureHotThresholdC: 28,
          temperatureHotMultiplier: 1.0,
          temperatureColdThresholdC: 15,
          temperatureColdMultiplier: 1.0,
          seasonMultipliers: {},
        );
    }
  }

  Map<String, Object?> toMap() => {
        'humidityEnabled': humidityEnabled,
        'temperatureEnabled': temperatureEnabled,
        'seasonEnabled': seasonEnabled,
        'humidityLowThresholdPercent': humidityLowThresholdPercent,
        'humidityLowMultiplier': humidityLowMultiplier,
        'humidityHighThresholdPercent': humidityHighThresholdPercent,
        'humidityHighMultiplier': humidityHighMultiplier,
        'temperatureHotThresholdC': temperatureHotThresholdC,
        'temperatureHotMultiplier': temperatureHotMultiplier,
        'temperatureColdThresholdC': temperatureColdThresholdC,
        'temperatureColdMultiplier': temperatureColdMultiplier,
        'seasonMultipliers': {
          for (final entry in seasonMultipliers.entries)
            entry.key.name: entry.value,
        },
      };

  factory CareRuleEnvironmentProfile.fromMap(Map<String, Object?> map) {
    try {
      final seasonMultipliersRaw =
          (map['seasonMultipliers'] as Map).cast<String, Object?>();
      final seasonMultipliers = <Season, double>{};
      for (final entry in seasonMultipliersRaw.entries) {
        seasonMultipliers[Season.values.byName(entry.key)] =
            (entry.value as num).toDouble();
      }
      return CareRuleEnvironmentProfile(
        humidityEnabled: map['humidityEnabled'] as bool,
        temperatureEnabled: map['temperatureEnabled'] as bool,
        seasonEnabled: map['seasonEnabled'] as bool,
        humidityLowThresholdPercent:
            (map['humidityLowThresholdPercent'] as num).toDouble(),
        humidityLowMultiplier: (map['humidityLowMultiplier'] as num).toDouble(),
        humidityHighThresholdPercent:
            (map['humidityHighThresholdPercent'] as num).toDouble(),
        humidityHighMultiplier:
            (map['humidityHighMultiplier'] as num).toDouble(),
        temperatureHotThresholdC:
            (map['temperatureHotThresholdC'] as num).toDouble(),
        temperatureHotMultiplier:
            (map['temperatureHotMultiplier'] as num).toDouble(),
        temperatureColdThresholdC:
            (map['temperatureColdThresholdC'] as num).toDouble(),
        temperatureColdMultiplier:
            (map['temperatureColdMultiplier'] as num).toDouble(),
        seasonMultipliers: seasonMultipliers,
      );
    } catch (e) {
      throw FormatException('Invalid CareRuleEnvironmentProfile map: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CareRuleEnvironmentProfile &&
      other.humidityEnabled == humidityEnabled &&
      other.temperatureEnabled == temperatureEnabled &&
      other.seasonEnabled == seasonEnabled &&
      other.humidityLowThresholdPercent == humidityLowThresholdPercent &&
      other.humidityLowMultiplier == humidityLowMultiplier &&
      other.humidityHighThresholdPercent == humidityHighThresholdPercent &&
      other.humidityHighMultiplier == humidityHighMultiplier &&
      other.temperatureHotThresholdC == temperatureHotThresholdC &&
      other.temperatureHotMultiplier == temperatureHotMultiplier &&
      other.temperatureColdThresholdC == temperatureColdThresholdC &&
      other.temperatureColdMultiplier == temperatureColdMultiplier &&
      mapEquals(other.seasonMultipliers, seasonMultipliers);

  @override
  int get hashCode => Object.hash(
        humidityEnabled,
        temperatureEnabled,
        seasonEnabled,
        humidityLowThresholdPercent,
        humidityLowMultiplier,
        humidityHighThresholdPercent,
        humidityHighMultiplier,
        temperatureHotThresholdC,
        temperatureHotMultiplier,
        temperatureColdThresholdC,
        temperatureColdMultiplier,
        Object.hashAll(seasonMultipliers.entries),
      );
}

class CareRule {
  final TaskType type;
  final double baseIntervalDays;
  final double minIntervalDays;
  final double maxIntervalDays;
  final List<String> guidance;
  final CareRuleEnvironmentProfile environmentProfile;

  const CareRule({
    required this.type,
    required this.baseIntervalDays,
    required this.minIntervalDays,
    required this.maxIntervalDays,
    required this.guidance,
    required this.environmentProfile,
  })  : assert(baseIntervalDays > 0),
        assert(minIntervalDays > 0),
        assert(maxIntervalDays >= minIntervalDays);

  factory CareRule.defaultsFor({
    required TaskType type,
    required double baseIntervalDays,
    double? minIntervalDays,
    double? maxIntervalDays,
    List<String>? guidance,
  }) =>
      CareRule(
        type: type,
        baseIntervalDays: baseIntervalDays,
        minIntervalDays: minIntervalDays ?? 1,
        maxIntervalDays: maxIntervalDays ?? 60,
        guidance: List.unmodifiable(guidance ?? const <String>[]),
        environmentProfile: CareRuleEnvironmentProfile.defaultsFor(type),
      );

  Map<String, Object?> toMap() => {
        'type': type.name,
        'baseIntervalDays': baseIntervalDays,
        'minIntervalDays': minIntervalDays,
        'maxIntervalDays': maxIntervalDays,
        'guidance': guidance,
        'environmentProfile': environmentProfile.toMap(),
      };

  factory CareRule.fromMap(Map<String, Object?> map) {
    try {
      return CareRule(
        type: TaskType.values.byName(map['type'] as String),
        baseIntervalDays: (map['baseIntervalDays'] as num).toDouble(),
        minIntervalDays: (map['minIntervalDays'] as num).toDouble(),
        maxIntervalDays: (map['maxIntervalDays'] as num).toDouble(),
        guidance: List<String>.unmodifiable((map['guidance'] as List).cast()),
        environmentProfile: CareRuleEnvironmentProfile.fromMap(
          (map['environmentProfile'] as Map).cast<String, Object?>(),
        ),
      );
    } catch (e) {
      throw FormatException('Invalid CareRule map: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CareRule &&
      other.type == type &&
      other.baseIntervalDays == baseIntervalDays &&
      other.minIntervalDays == minIntervalDays &&
      other.maxIntervalDays == maxIntervalDays &&
      listEquals(other.guidance, guidance) &&
      other.environmentProfile == environmentProfile;

  @override
  int get hashCode => Object.hash(
        type,
        baseIntervalDays,
        minIntervalDays,
        maxIntervalDays,
        Object.hashAll(guidance),
        environmentProfile,
      );
}

class CareRuleSet {
  final String id;
  final String? speciesId;
  final int schemaVersion;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final Map<TaskType, CareRule> rules;

  CareRuleSet({
    required this.id,
    required this.rules,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    this.speciesId,
    this.schemaVersion = 1,
  })  : createdAtUtc = (createdAtUtc ?? DateTime.now()).toUtc(),
        updatedAtUtc = (updatedAtUtc ?? DateTime.now()).toUtc();

  Map<String, Object?> toMap() => {
        'id': id,
        if (speciesId != null) 'speciesId': speciesId,
        'schemaVersion': schemaVersion,
        'createdAtUtcMs': encodeUtcMillis(createdAtUtc),
        'updatedAtUtcMs': encodeUtcMillis(updatedAtUtc),
        'rules': [for (final rule in rules.values) rule.toMap()],
      };

  factory CareRuleSet.fromMap(Map<String, Object?> map) {
    try {
      final rulesList = (map['rules'] as List).cast<Map>();
      final rules = <TaskType, CareRule>{};
      for (final raw in rulesList) {
        final rule = CareRule.fromMap(raw.cast<String, Object?>());
        rules[rule.type] = rule;
      }

      return CareRuleSet(
        id: map['id'] as String,
        speciesId: map['speciesId'] as String?,
        schemaVersion: map['schemaVersion'] as int? ?? 1,
        createdAtUtc: decodeUtcMillis(map['createdAtUtcMs'] as int),
        updatedAtUtc: decodeUtcMillis(map['updatedAtUtcMs'] as int),
        rules: rules,
      );
    } catch (e) {
      throw FormatException('Invalid CareRuleSet map: $e');
    }
  }
}
