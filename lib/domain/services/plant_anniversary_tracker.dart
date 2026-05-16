import '../models/plant.dart';

class PlantAnniversary {
  const PlantAnniversary({
    required this.plantId,
    required this.plantNickname,
    required this.years,
    required this.daysUntil,
    required this.messageKey,
    required this.milestone,
  });

  final String plantId;
  final String plantNickname;
  final int years;
  final int daysUntil;
  final String messageKey;
  final bool milestone;
}

class AnniversaryReport {
  const AnniversaryReport({
    required this.upcoming,
    required this.today,
    required this.oldestPlantDays,
    required this.avgPlantAge,
  });

  final List<PlantAnniversary> upcoming;
  final List<PlantAnniversary> today;
  final int oldestPlantDays;
  final double avgPlantAge;
}

class PlantAnniversaryTracker {
  const PlantAnniversaryTracker._();

  static AnniversaryReport check({
    required List<Plant> plants,
    required DateTime now,
    required int lookAheadDays,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    if (active.isEmpty) {
      return const AnniversaryReport(
        upcoming: [], today: [], oldestPlantDays: 0, avgPlantAge: 0,
      );
    }

    final today = <PlantAnniversary>[];
    final upcoming = <PlantAnniversary>[];

    for (final plant in active) {
      final age = now.difference(plant.createdAt).inDays;
      final years = age ~/ 365;
      if (years < 1 && age < 30) continue;

      final nextAnniversary = _nextAnniversary(plant.createdAt, now);
      final daysUntil = nextAnniversary.difference(now).inDays;
      final anniversaryYears = nextAnniversary.year - plant.createdAt.year;

      if (daysUntil == 0) {
        today.add(PlantAnniversary(
          plantId: plant.id, plantNickname: plant.nickname,
          years: anniversaryYears, daysUntil: 0,
          messageKey: _message(anniversaryYears),
          milestone: anniversaryYears == 1 || anniversaryYears % 5 == 0,
        ));
      } else if (daysUntil <= lookAheadDays && daysUntil > 0) {
        upcoming.add(PlantAnniversary(
          plantId: plant.id, plantNickname: plant.nickname,
          years: anniversaryYears, daysUntil: daysUntil,
          messageKey: _message(anniversaryYears),
          milestone: anniversaryYears == 1 || anniversaryYears % 5 == 0,
        ));
      }

      if (age >= 30 && age <= 30 + lookAheadDays) {
        upcoming.add(PlantAnniversary(
          plantId: plant.id, plantNickname: plant.nickname,
          years: 0, daysUntil: 30 - (age > 30 ? 0 : 30 - age),
          messageKey: 'anniversaryOneMonth',
          milestone: false,
        ));
      }
    }

    upcoming.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    final ages = active.map((p) => now.difference(p.createdAt).inDays).toList();
    final oldest = ages.reduce((a, b) => a > b ? a : b);
    final avg = ages.reduce((a, b) => a + b) / ages.length;

    return AnniversaryReport(
      upcoming: upcoming, today: today,
      oldestPlantDays: oldest, avgPlantAge: avg,
    );
  }

  static DateTime _nextAnniversary(DateTime created, DateTime now) {
    var next = DateTime(now.year, created.month, created.day);
    if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
      if (next.isBefore(now) && next.day == now.day && next.month == now.month) {
        return next;
      }
      if (next.isBefore(now)) {
        next = DateTime(now.year + 1, created.month, created.day);
      }
    }
    return next;
  }

  static String _message(int years) {
    if (years >= 5) return 'anniversaryVeteran';
    if (years >= 3) return 'anniversaryDedicated';
    if (years >= 1) return 'anniversaryFirstYear';
    return 'anniversaryOneMonth';
  }
}
