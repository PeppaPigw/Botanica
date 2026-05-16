import '../models/plant.dart';
import '../models/species.dart';

enum CompatibilityLevel { excellent, good, neutral, poor }

class PlantPairing {
  const PlantPairing({
    required this.plantAId,
    required this.plantANickname,
    required this.plantBId,
    required this.plantBNickname,
    required this.compatibility,
    required this.reasons,
    required this.room,
  });

  final String plantAId;
  final String plantANickname;
  final String plantBId;
  final String plantBNickname;
  final CompatibilityLevel compatibility;
  final List<CompatibilityReason> reasons;
  final String room;
}

class CompatibilityReason {
  const CompatibilityReason({
    required this.factor,
    required this.isPositive,
    required this.messageKey,
  });

  final String factor;
  final bool isPositive;
  final String messageKey;
}

class RoomCompatibilityReport {
  const RoomCompatibilityReport({
    required this.room,
    required this.overallScore,
    required this.pairings,
    required this.suggestion,
  });

  final String room;
  final double overallScore;
  final List<PlantPairing> pairings;
  final String? suggestion;
}

class CompanionPlantAnalyzer {
  const CompanionPlantAnalyzer._();

  static List<RoomCompatibilityReport> analyzeByRoom({
    required List<Plant> plants,
    required List<Species> species,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final rooms = activePlants.map((p) => p.room).where((r) => r.isNotEmpty).toSet();

    final reports = <RoomCompatibilityReport>[];

    for (final room in rooms) {
      final roomPlants = activePlants.where((p) => p.room == room).toList();
      if (roomPlants.length < 2) continue;

      final pairings = <PlantPairing>[];
      double totalScore = 0;
      int pairCount = 0;

      for (int i = 0; i < roomPlants.length; i++) {
        for (int j = i + 1; j < roomPlants.length; j++) {
          final pairing = _analyzePair(
            roomPlants[i], roomPlants[j], species, room);
          if (pairing != null) {
            pairings.add(pairing);
            totalScore += pairing.compatibility.index;
            pairCount++;
          }
        }
      }

      if (pairings.isEmpty) continue;

      final avgScore = totalScore / pairCount;
      final suggestion = _generateSuggestion(pairings, avgScore);

      reports.add(RoomCompatibilityReport(
        room: room,
        overallScore: (1.0 - avgScore / 3.0).clamp(0.0, 1.0),
        pairings: pairings,
        suggestion: suggestion,
      ));
    }

    reports.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return reports;
  }

  static List<PlantPairing> findBestCompanions({
    required List<Plant> plants,
    required List<Species> species,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 2) return [];

    final pairings = <PlantPairing>[];

    for (int i = 0; i < activePlants.length; i++) {
      for (int j = i + 1; j < activePlants.length; j++) {
        final pairing = _analyzePair(
          activePlants[i], activePlants[j], species, '');
        if (pairing != null &&
            pairing.compatibility == CompatibilityLevel.excellent) {
          pairings.add(pairing);
        }
      }
    }

    pairings.sort((a, b) => a.reasons.length.compareTo(b.reasons.length));
    return pairings.reversed.take(5).toList();
  }

  static List<PlantPairing> findConflicts({
    required List<Plant> plants,
    required List<Species> species,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 2) return [];

    final conflicts = <PlantPairing>[];

    for (int i = 0; i < activePlants.length; i++) {
      for (int j = i + 1; j < activePlants.length; j++) {
        if (activePlants[i].room != activePlants[j].room) continue;
        if (activePlants[i].room.isEmpty) continue;

        final pairing = _analyzePair(
          activePlants[i], activePlants[j], species, activePlants[i].room);
        if (pairing != null &&
            pairing.compatibility == CompatibilityLevel.poor) {
          conflicts.add(pairing);
        }
      }
    }

    return conflicts;
  }

  static PlantPairing? _analyzePair(
    Plant a,
    Plant b,
    List<Species> species,
    String room,
  ) {
    final specA = species.where((s) => s.id == a.speciesId).firstOrNull;
    final specB = species.where((s) => s.id == b.speciesId).firstOrNull;
    if (specA == null || specB == null) return null;

    final reasons = <CompatibilityReason>[];

    _compareLightNeeds(specA, specB, reasons);
    _compareWaterNeeds(specA, specB, reasons);
    _compareGrowthRate(specA, specB, reasons);
    _checkToxicityConflict(specA, specB, reasons);

    final positiveCount = reasons.where((r) => r.isPositive).length;
    final negativeCount = reasons.where((r) => !r.isPositive).length;

    final CompatibilityLevel level;
    if (negativeCount == 0 && positiveCount >= 2) {
      level = CompatibilityLevel.excellent;
    } else if (negativeCount == 0 || positiveCount > negativeCount) {
      level = CompatibilityLevel.good;
    } else if (negativeCount > positiveCount) {
      level = CompatibilityLevel.poor;
    } else {
      level = CompatibilityLevel.neutral;
    }

    return PlantPairing(
      plantAId: a.id,
      plantANickname: a.nickname,
      plantBId: b.id,
      plantBNickname: b.nickname,
      compatibility: level,
      reasons: reasons,
      room: room,
    );
  }

  static void _compareLightNeeds(
      Species a, Species b, List<CompatibilityReason> out) {
    final lightA = a.light.toLowerCase();
    final lightB = b.light.toLowerCase();

    if (_lightCategory(lightA) == _lightCategory(lightB)) {
      out.add(const CompatibilityReason(
        factor: 'light',
        isPositive: true,
        messageKey: 'companionSameLight',
      ));
    } else if ((_lightCategory(lightA) - _lightCategory(lightB)).abs() >= 2) {
      out.add(const CompatibilityReason(
        factor: 'light',
        isPositive: false,
        messageKey: 'companionConflictLight',
      ));
    }
  }

  static void _compareWaterNeeds(
      Species a, Species b, List<CompatibilityReason> out) {
    final waterA = a.careDefaults.waterBaseDays;
    final waterB = b.careDefaults.waterBaseDays;

    final diff = (waterA - waterB).abs();
    if (diff <= 2) {
      out.add(const CompatibilityReason(
        factor: 'water',
        isPositive: true,
        messageKey: 'companionSameWater',
      ));
    } else if (diff >= 7) {
      out.add(const CompatibilityReason(
        factor: 'water',
        isPositive: false,
        messageKey: 'companionConflictWater',
      ));
    }
  }

  static void _compareGrowthRate(
      Species a, Species b, List<CompatibilityReason> out) {
    final rateA = a.growth?.rate.toLowerCase() ?? 'moderate';
    final rateB = b.growth?.rate.toLowerCase() ?? 'moderate';

    if (rateA == rateB) {
      out.add(const CompatibilityReason(
        factor: 'growth',
        isPositive: true,
        messageKey: 'companionSameGrowth',
      ));
    } else if ((rateA == 'fast' && rateB == 'slow') ||
        (rateA == 'slow' && rateB == 'fast')) {
      out.add(const CompatibilityReason(
        factor: 'growth',
        isPositive: false,
        messageKey: 'companionConflictGrowth',
      ));
    }
  }

  static void _checkToxicityConflict(
      Species a, Species b, List<CompatibilityReason> out) {
    if (a.petSafe && b.petSafe) {
      out.add(const CompatibilityReason(
        factor: 'safety',
        isPositive: true,
        messageKey: 'companionBothPetSafe',
      ));
    }
  }

  static int _lightCategory(String light) {
    if (light.contains('low') || light.contains('shade')) return 0;
    if (light.contains('indirect') || light.contains('medium')) return 1;
    if (light.contains('bright') && !light.contains('direct')) return 2;
    if (light.contains('direct') || light.contains('full')) return 3;
    return 1;
  }

  static String? _generateSuggestion(
      List<PlantPairing> pairings, double avgScore) {
    final poorPairings = pairings
        .where((p) => p.compatibility == CompatibilityLevel.poor)
        .toList();

    if (poorPairings.isEmpty) return null;

    final lightConflicts = poorPairings
        .where((p) => p.reasons.any((r) => r.factor == 'light' && !r.isPositive))
        .toList();

    if (lightConflicts.isNotEmpty) {
      return 'suggestSeparateByLight';
    }

    final waterConflicts = poorPairings
        .where((p) => p.reasons.any((r) => r.factor == 'water' && !r.isPositive))
        .toList();

    if (waterConflicts.isNotEmpty) {
      return 'suggestGroupByWater';
    }

    return 'suggestReviewPlacements';
  }
}
