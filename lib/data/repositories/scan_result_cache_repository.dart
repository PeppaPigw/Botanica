import 'package:hive_flutter/hive_flutter.dart';

import '../local/local_db.dart';

class CachedScanResult {
  const CachedScanResult({
    required this.speciesId,
    required this.confidence,
    required this.scannedAt,
  });

  final String speciesId;
  final double confidence;
  final DateTime scannedAt;
}

class ScanResultCacheRepository {
  const ScanResultCacheRepository(this._box);

  static const String _key = 'last_scan_result_v1';

  final Box<Map> _box;

  factory ScanResultCacheRepository.local() =>
      ScanResultCacheRepository(LocalDb.settingsBox);

  CachedScanResult? readLast() => _parse(_box.get(_key));

  Stream<CachedScanResult?> watchLast() async* {
    yield readLast();
    yield* _box.watch(key: _key).map((_) => readLast());
  }

  Future<void> save({
    required String speciesId,
    required double confidence,
  }) async {
    final id = speciesId.trim();
    if (id.isEmpty) return;

    await _box.put(
      _key,
      <String, dynamic>{
        'speciesId': id,
        'confidence': confidence.clamp(0.0, 1.0),
        'scannedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  CachedScanResult? _parse(Map? raw) {
    if (raw == null) return null;
    final json = Map<String, dynamic>.from(raw);
    final speciesId = (json['speciesId'] as String?)?.trim() ?? '';
    if (speciesId.isEmpty) return null;
    final scannedAt = DateTime.tryParse(json['scannedAt'] as String? ?? '');
    return CachedScanResult(
      speciesId: speciesId,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      scannedAt: scannedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
