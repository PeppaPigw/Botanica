import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:botanica/data/migrations/hive_migrator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HiveMigrator runs v0->v1 and persists schema version', () async {
    final dir =
        await Directory.systemTemp.createTemp('botanica_hive_migrator_test_');
    Hive.init(dir.path);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final settingsBox = await Hive.openBox<Map>('settings_$suffix');

    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final migrator = HiveMigrator(
      hive: Hive,
      settingsBox: settingsBox,
      migrations: HiveMigrator.defaultMigrations,
    );

    expect(migrator.readSchemaVersion(), 0);

    await migrator.run();

    expect(migrator.readSchemaVersion(), 1);

    final raw = settingsBox.get(HiveSchemaVersionStore.entryKey);
    expect(raw, isNotNull);
    expect(Map<String, dynamic>.from(raw!)['schemaVersion'], 1);
  });

  test('HiveMigrator is idempotent when already at latest', () async {
    final dir = await Directory.systemTemp
        .createTemp('botanica_hive_migrator_idempotent_test_');
    Hive.init(dir.path);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final settingsBox = await Hive.openBox<Map>('settings_$suffix');
    await settingsBox.put(
      HiveSchemaVersionStore.entryKey,
      <String, Object?>{'schemaVersion': 1},
    );

    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final migrator = HiveMigrator(
      hive: Hive,
      settingsBox: settingsBox,
      migrations: HiveMigrator.defaultMigrations,
    );

    await migrator.run();
    expect(migrator.readSchemaVersion(), 1);
  });

  test('HiveMigrator throws when a required step is missing', () async {
    final dir = await Directory.systemTemp
        .createTemp('botanica_hive_migrator_missing_step_test_');
    Hive.init(dir.path);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final settingsBox = await Hive.openBox<Map>('settings_$suffix');

    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final migrator = HiveMigrator(
      hive: Hive,
      settingsBox: settingsBox,
      migrations: <HiveMigrationStep>[
        HiveMigrationStep(
          fromVersion: 1,
          toVersion: 2,
          migrate: (context) async {},
        ),
      ],
    );

    await expectLater(migrator.run(), throwsA(isA<StateError>()));
    expect(migrator.readSchemaVersion(), 0);
  });

  test('HiveMigrator does not downgrade newer schemas', () async {
    final dir = await Directory.systemTemp
        .createTemp('botanica_hive_migrator_no_downgrade_test_');
    Hive.init(dir.path);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final settingsBox = await Hive.openBox<Map>('settings_$suffix');
    await settingsBox.put(
      HiveSchemaVersionStore.entryKey,
      <String, Object?>{'schemaVersion': 99},
    );

    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final migrator = HiveMigrator(
      hive: Hive,
      settingsBox: settingsBox,
      migrations: HiveMigrator.defaultMigrations,
    );

    await migrator.run();
    expect(migrator.readSchemaVersion(), 99);
  });
}
