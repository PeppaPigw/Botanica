import 'dart:math';

import 'package:hive/hive.dart';

import '../local/local_db.dart';

typedef HiveMigrationFn = Future<void> Function(HiveMigrationContext context);

final class HiveMigrationContext {
  HiveMigrationContext({
    required this.hive,
    required this.settingsBox,
  });

  final HiveInterface hive;
  final Box<Map> settingsBox;
}

final class HiveMigrationStep {
  HiveMigrationStep({
    required this.fromVersion,
    required this.toVersion,
    required this.migrate,
  })  : assert(fromVersion >= 0),
        assert(toVersion > fromVersion);

  final int fromVersion;
  final int toVersion;
  final HiveMigrationFn migrate;
}

final class HiveSchemaVersionStore {
  HiveSchemaVersionStore(this._settingsBox);

  static const String entryKey = 'schema_version';
  static const String versionField = 'schemaVersion';

  final Box<Map> _settingsBox;

  int read() {
    final raw = _settingsBox.get(entryKey);
    if (raw == null) return 0;

    final map = Map<dynamic, dynamic>.from(raw);
    final dynamic value = map[versionField] ?? map['version'];

    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> write(int version) async {
    if (version < 0) {
      throw ArgumentError.value(version, 'version', 'Must be >= 0');
    }

    await _settingsBox.put(entryKey, <String, Object?>{versionField: version});
  }
}

final class HiveMigrator {
  HiveMigrator({
    required HiveInterface hive,
    required Box<Map> settingsBox,
    required List<HiveMigrationStep> migrations,
  })  : _hive = hive,
        _settingsBox = settingsBox,
        _schemaVersionStore = HiveSchemaVersionStore(settingsBox),
        _registry = _buildRegistry(migrations);

  factory HiveMigrator.forLocalDb({HiveInterface? hive}) {
    return HiveMigrator(
      hive: hive ?? Hive,
      settingsBox: LocalDb.settingsBox,
      migrations: defaultMigrations,
    );
  }

  static final List<HiveMigrationStep> defaultMigrations = <HiveMigrationStep>[
    HiveMigrationStep(
      fromVersion: 0,
      toVersion: 1,
      migrate: _noopV0ToV1,
    ),
  ];

  final HiveInterface _hive;
  final Box<Map> _settingsBox;
  final HiveSchemaVersionStore _schemaVersionStore;
  final Map<int, HiveMigrationStep> _registry;

  Future<void>? _runFuture;

  int get latestVersion {
    var latest = 0;
    for (final step in _registry.values) {
      latest = max(latest, step.toVersion);
    }
    return latest;
  }

  int readSchemaVersion() => _schemaVersionStore.read();

  Future<void> run() {
    final existing = _runFuture;
    if (existing != null) return existing;

    final future = _runInternal();
    _runFuture = future;
    return future;
  }

  Future<void> _runInternal() async {
    var currentVersion = _schemaVersionStore.read();
    if (currentVersion < 0) currentVersion = 0;

    final targetVersion = latestVersion;

    if (currentVersion > targetVersion) {
      return;
    }

    final context = HiveMigrationContext(
      hive: _hive,
      settingsBox: _settingsBox,
    );

    while (currentVersion < targetVersion) {
      final step = _registry[currentVersion];
      if (step == null) {
        throw StateError(
          'Missing Hive migration from v$currentVersion '
          '(known target v$targetVersion).',
        );
      }

      await step.migrate(context);

      await _schemaVersionStore.write(step.toVersion);
      currentVersion = step.toVersion;
    }
  }

  static Map<int, HiveMigrationStep> _buildRegistry(
    List<HiveMigrationStep> migrations,
  ) {
    final registry = <int, HiveMigrationStep>{};
    for (final migration in migrations) {
      final existing = registry[migration.fromVersion];
      if (existing != null) {
        throw ArgumentError(
          'Duplicate Hive migration from v${migration.fromVersion} '
          '(to v${existing.toVersion} and v${migration.toVersion}).',
        );
      }
      registry[migration.fromVersion] = migration;
    }
    return Map<int, HiveMigrationStep>.unmodifiable(registry);
  }

  static Future<void> _noopV0ToV1(HiveMigrationContext context) async {}
}
