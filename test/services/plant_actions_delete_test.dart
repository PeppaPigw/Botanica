import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:botanica/data/repositories/diary_repository.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/data/repositories/photos_repository.dart';
import 'package:botanica/data/repositories/plants_repository.dart';
import 'package:botanica/data/repositories/tasks_repository.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/services/plants/plant_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PlantActions.deletePlantCascade deletes plant and related records',
      () async {
    final dir =
        await Directory.systemTemp.createTemp('botanica_hive_delete_test_');
    Hive.init(dir.path);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final plantsBox = await Hive.openBox<Map>('plants_$suffix');
    final tasksBox = await Hive.openBox<Map>('tasks_$suffix');
    final logsBox = await Hive.openBox<Map>('logs_$suffix');
    final photosBox = await Hive.openBox<Map>('photos_$suffix');
    final diaryBox = await Hive.openBox<Map>('diary_$suffix');

    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final plantsRepo = PlantsRepository(plantsBox);
    final tasksRepo = TasksRepository(tasksBox);
    final logsRepo = LogsRepository(logsBox);
    final photosRepo = PhotosRepository(photosBox);
    final diaryRepo = DiaryRepository(diaryBox);

    final now = DateTime.utc(2026, 2, 21, 12);

    const plantAId = 'plant_a';
    const plantBId = 'plant_b';
    final photoAFile = File('${dir.path}/photo_a.jpg');
    final photoBFile = File('${dir.path}/photo_b.jpg');
    await photoAFile.writeAsBytes(<int>[1, 2, 3]);
    await photoBFile.writeAsBytes(<int>[4, 5, 6]);

    await plantsRepo.upsert(
      Plant(
        id: plantAId,
        nickname: 'A',
        speciesId: 'monstera_deliciosa',
        room: 'Living',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: 'assets/placeholders/species/monstera_deliciosa.png',
        createdAt: now,
        meta: const PlantMeta(),
      ),
    );

    await plantsRepo.upsert(
      Plant(
        id: plantBId,
        nickname: 'B',
        speciesId: 'epipremnum_aureum',
        room: 'Bedroom',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: 'assets/placeholders/species/epipremnum_aureum.png',
        createdAt: now,
        meta: const PlantMeta(),
      ),
    );

    await tasksRepo.upsert(
      TaskInstance(
        id: 'task_a',
        plantId: plantAId,
        type: TaskType.water,
        dueAt: now.add(const Duration(days: 3)),
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      ),
    );

    await tasksRepo.upsert(
      TaskInstance(
        id: 'task_b',
        plantId: plantBId,
        type: TaskType.water,
        dueAt: now.add(const Duration(days: 2)),
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      ),
    );

    await logsRepo.add(
      CareLog(
        id: 'log_a',
        plantId: plantAId,
        type: TaskType.water,
        timestamp: now,
        note: null,
        linkedPhotoId: null,
      ),
    );

    await photosRepo.add(
      PhotoEntry(
        id: 'photo_a',
        plantId: plantAId,
        filePath: photoAFile.path,
        createdAt: now,
        note: null,
        hash: null,
      ),
    );

    await photosRepo.add(
      PhotoEntry(
        id: 'photo_b',
        plantId: plantBId,
        filePath: photoBFile.path,
        createdAt: now,
        note: null,
        hash: null,
      ),
    );

    await diaryRepo.add(
      DiaryEntry(
        id: 'diary_a',
        plantId: plantAId,
        createdAt: now,
        text: 'Note',
      ),
    );

    await PlantActions.deletePlantCascade(
      plantId: plantAId,
      plantsRepository: plantsRepo,
      tasksRepository: tasksRepo,
      logsRepository: logsRepo,
      photosRepository: photosRepo,
      diaryRepository: diaryRepo,
    );

    expect(plantsRepo.byId(plantAId), isNull);
    expect(tasksRepo.forPlant(plantAId), isEmpty);
    expect(logsRepo.forPlant(plantAId), isEmpty);
    expect(photosRepo.forPlant(plantAId), isEmpty);
    expect(diaryRepo.forPlant(plantAId), isEmpty);
    expect(photoAFile.existsSync(), isFalse);

    // Unrelated plant remains.
    expect(plantsRepo.byId(plantBId), isNotNull);
    expect(tasksRepo.forPlant(plantBId), isNotEmpty);
    expect(photosRepo.forPlant(plantBId), isNotEmpty);
    expect(photoBFile.existsSync(), isTrue);
  });
}
