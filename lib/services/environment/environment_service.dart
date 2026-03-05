import 'package:geolocator/geolocator.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../data/repositories/environment_repository.dart';
import '../../domain/models/environment_snapshot.dart';
import 'open_meteo_client.dart';

class EnvironmentService {
  const EnvironmentService({
    required EnvironmentRepository repository,
    required OpenMeteoClient openMeteo,
    this.cacheTtl = const Duration(hours: 1),
  })  : _repository = repository,
        _openMeteo = openMeteo;

  final EnvironmentRepository _repository;
  final OpenMeteoClient _openMeteo;
  final Duration cacheTtl;

  EnvironmentSnapshot? readCached() => _repository.readCached();

  Future<EnvironmentSnapshot> getSnapshot({
    bool forceRefresh = false,
    bool allowPermissionPrompt = false,
  }) async {
    final now = DateTime.now();
    final cached = _repository.readCached();
    if (!forceRefresh && cached != null) {
      final age = now.difference(cached.timestamp);
      if (age >= Duration.zero && age <= cacheTtl) {
        return cached;
      }
    }

    try {
      final fresh = await _fetchFresh(
        now: now,
        allowPermissionPrompt: allowPermissionPrompt,
      );
      await _repository.write(fresh);
      return fresh;
    } catch (_) {
      // Offline-first: if fetch fails, show cached or a calm default.
      return cached ??
          EnvironmentSnapshot(
            timestamp: now,
            tempC: 24,
            humidity: 48,
          );
    }
  }

  Future<EnvironmentSnapshot> _fetchFresh({
    required DateTime now,
    required bool allowPermissionPrompt,
  }) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw StateError('Location services disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && allowPermissionPrompt) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission denied');
    }

    Position? position;
    try {
      position = await Geolocator.getLastKnownPosition();
    } catch (_) {
      position = null;
    }

    position ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    String? timezoneName;
    try {
      timezoneName = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      timezoneName = null;
    }

    return _openMeteo.fetchCurrent(
      lat: position.latitude,
      lon: position.longitude,
      timezone: timezoneName,
    );
  }
}
