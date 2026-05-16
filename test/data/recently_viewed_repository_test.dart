import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:botanica/data/repositories/recently_viewed_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<Map> box;

  setUp(() async {
    tempDir = await Directory.systemTemp
        .createTemp('botanica_recently_viewed_test_');
    Hive.init(tempDir.path);
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    box = await Hive.openBox<Map>('settings_rv_$suffix');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('readIds returns empty list initially', () {
    final repo = RecentlyViewedRepository(box);
    expect(repo.readIds(), isEmpty);
  });

  test('markViewed adds species to the front', () async {
    final repo = RecentlyViewedRepository(box);
    await repo.markViewed('species_a');
    await repo.markViewed('species_b');

    final ids = repo.readIds();
    expect(ids, ['species_b', 'species_a']);
  });

  test('markViewed deduplicates and moves to front', () async {
    final repo = RecentlyViewedRepository(box);
    await repo.markViewed('species_a');
    await repo.markViewed('species_b');
    await repo.markViewed('species_a');

    final ids = repo.readIds();
    expect(ids, ['species_a', 'species_b']);
  });

  test('markViewed caps at 10 items', () async {
    final repo = RecentlyViewedRepository(box);
    for (int i = 0; i < 15; i++) {
      await repo.markViewed('species_$i');
    }

    final ids = repo.readIds();
    expect(ids.length, 10);
    expect(ids.first, 'species_14');
    expect(ids.last, 'species_5');
  });

  test('markViewed ignores empty strings', () async {
    final repo = RecentlyViewedRepository(box);
    await repo.markViewed('');
    await repo.markViewed('  ');

    expect(repo.readIds(), isEmpty);
  });

  test('watchIds emits updates', () async {
    final repo = RecentlyViewedRepository(box);

    final stream = repo.watchIds();
    final results = <List<String>>[];
    final sub = stream.listen(results.add);

    // Allow initial emission
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await repo.markViewed('species_x');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await sub.cancel();

    expect(results.length, greaterThanOrEqualTo(2));
    expect(results.first, isEmpty);
    expect(results.last, contains('species_x'));
  });
}
