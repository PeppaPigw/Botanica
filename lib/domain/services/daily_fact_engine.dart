import '../models/plant.dart';
import '../models/species.dart';

class DailyPlantFact {
  const DailyPlantFact({
    required this.plantId,
    required this.plantNickname,
    required this.factKey,
    required this.args,
  });

  final String plantId;
  final String plantNickname;
  final String factKey;
  final Map<String, String> args;
}

class DailyFactEngine {
  const DailyFactEngine._();

  static DailyPlantFact? generate({
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) return null;

    final dayIndex = now.millisecondsSinceEpoch ~/ 86400000;
    final plantIndex = dayIndex % activePlants.length;
    final plant = activePlants[plantIndex];
    final species = speciesMap[plant.speciesId];

    if (species == null) return null;

    final facts = _factsForSpecies(species, plant);
    if (facts.isEmpty) return null;

    final factIndex = dayIndex % facts.length;
    final fact = facts[factIndex];

    return DailyPlantFact(
      plantId: plant.id,
      plantNickname: plant.nickname,
      factKey: fact.key,
      args: fact.args,
    );
  }

  static List<_FactCandidate> _factsForSpecies(Species species, Plant plant) {
    final facts = <_FactCandidate>[];

    if (species.origin != null) {
      final range = species.origin!.nativeRange('en');
      if (range != null && range.isNotEmpty) {
        facts.add(_FactCandidate(
          key: 'factOrigin',
          args: {'plant': plant.nickname, 'region': range},
        ));
      }
    }

    facts.add(_FactCandidate(
      key: 'factWaterFrequency',
      args: {
        'plant': plant.nickname,
        'days': species.careDefaults.waterBaseDays.toString(),
      },
    ));

    final lightDesc = species.light;
    if (lightDesc.isNotEmpty) {
      facts.add(_FactCandidate(
        key: 'factLightPreference',
        args: {'plant': plant.nickname, 'light': lightDesc},
      ));
    }

    if (species.petSafe) {
      facts.add(_FactCandidate(
        key: 'factPetSafe',
        args: {'plant': plant.nickname},
      ));
    } else {
      facts.add(_FactCandidate(
        key: 'factToxic',
        args: {'plant': plant.nickname},
      ));
    }

    if (species.growth != null) {
      final rate = species.growth!.rate;
      if (rate.isNotEmpty) {
        facts.add(_FactCandidate(
          key: 'factGrowthRate',
          args: {'plant': plant.nickname, 'rate': rate},
        ));
      }
    }

    if (species.matureSize != null) {
      final maxHeight = species.matureSize!.heightCm.max;
      if (maxHeight > 0) {
        facts.add(_FactCandidate(
          key: 'factMatureHeight',
          args: {'plant': plant.nickname, 'height': maxHeight.toString()},
        ));
      }
    }

    return facts;
  }
}

class _FactCandidate {
  const _FactCandidate({required this.key, required this.args});
  final String key;
  final Map<String, String> args;
}
