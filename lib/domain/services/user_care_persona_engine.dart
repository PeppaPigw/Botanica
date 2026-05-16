import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class CarePersona {
  const CarePersona({
    required this.primaryType,
    required this.secondaryType,
    required this.strengths,
    required this.growthAreas,
    required this.description,
    required this.matchPercentage,
  });

  final String primaryType;
  final String? secondaryType;
  final List<String> strengths;
  final List<String> growthAreas;
  final String description;
  final double matchPercentage;
}

class UserCarePersonaEngine {
  const UserCarePersonaEngine._();

  static CarePersona analyze({
    required List<Plant> plants,
    required List<CareLog> logs,
    required int streakDays,
    required int totalDaysActive,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    final recentLogs = logs.where((l) => now.difference(l.timestamp).inDays <= 30).toList();

    final traits = _computeTraits(active, recentLogs, streakDays, totalDaysActive);
    final primary = _primaryPersona(traits);
    final secondary = _secondaryPersona(traits, primary);
    final strengths = _strengths(traits);
    final growthAreas = _growthAreas(traits);
    final match = _matchPercentage(traits, primary);

    return CarePersona(
      primaryType: primary,
      secondaryType: secondary,
      strengths: strengths,
      growthAreas: growthAreas,
      description: 'persona${primary}Desc',
      matchPercentage: match,
    );
  }

  static Map<String, double> _computeTraits(
      List<Plant> plants, List<CareLog> logs, int streak, int daysActive) {
    final traits = <String, double>{};

    traits['consistency'] = streak > 0 ? (streak / 30.0).clamp(0.0, 1.0) : 0.0;
    traits['volume'] = logs.isNotEmpty ? (logs.length / 60.0).clamp(0.0, 1.0) : 0.0;
    traits['diversity'] = plants.length >= 3
        ? (plants.map((p) => p.speciesId).toSet().length / plants.length).clamp(0.0, 1.0)
        : 0.0;

    final types = logs.map((l) => l.type).toSet();
    traits['thoroughness'] = (types.length / TaskType.values.length).clamp(0.0, 1.0);

    final hours = logs.map((l) => l.timestamp.hour).toList();
    final morningCount = hours.where((h) => h >= 6 && h < 12).length;
    traits['earlyBird'] = logs.length >= 10 ? morningCount / logs.length : 0.0;

    traits['experience'] = (daysActive / 365.0).clamp(0.0, 1.0);

    return traits;
  }

  static String _primaryPersona(Map<String, double> traits) {
    if ((traits['consistency'] ?? 0) >= 0.8 && (traits['volume'] ?? 0) >= 0.6) {
      return 'Devotee';
    }
    if ((traits['diversity'] ?? 0) >= 0.7) return 'Explorer';
    if ((traits['thoroughness'] ?? 0) >= 0.7) return 'Perfectionist';
    if ((traits['volume'] ?? 0) >= 0.7) return 'Nurturer';
    if ((traits['experience'] ?? 0) >= 0.7) return 'Veteran';
    if ((traits['earlyBird'] ?? 0) >= 0.7) return 'EarlyBird';
    return 'Casual';
  }

  static String? _secondaryPersona(Map<String, double> traits, String primary) {
    final sorted = traits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.length < 2) return null;

    final secondTrait = sorted[1].key;
    final persona = _traitToPersona(secondTrait);
    return persona != primary ? persona : null;
  }

  static String _traitToPersona(String trait) {
    switch (trait) {
      case 'consistency': return 'Devotee';
      case 'diversity': return 'Explorer';
      case 'thoroughness': return 'Perfectionist';
      case 'earlyBird': return 'EarlyBird';
      case 'volume': return 'Nurturer';
      case 'experience': return 'Veteran';
      default: return 'Casual';
    }
  }

  static List<String> _strengths(Map<String, double> traits) {
    return traits.entries
        .where((e) => e.value >= 0.6)
        .map((e) => 'strength_${e.key}')
        .take(3)
        .toList();
  }

  static List<String> _growthAreas(Map<String, double> traits) {
    return traits.entries
        .where((e) => e.value < 0.4)
        .map((e) => 'growth_${e.key}')
        .take(2)
        .toList();
  }

  static double _matchPercentage(Map<String, double> traits, String persona) {
    final relevantTrait = switch (persona) {
      'Devotee' => traits['consistency'] ?? 0,
      'Explorer' => traits['diversity'] ?? 0,
      'Perfectionist' => traits['thoroughness'] ?? 0,
      'EarlyBird' => traits['earlyBird'] ?? 0,
      'Nurturer' => traits['volume'] ?? 0,
      'Veteran' => traits['experience'] ?? 0,
      _ => 0.5,
    };
    return (relevantTrait * 100).clamp(50.0, 99.0) / 100.0;
  }
}
