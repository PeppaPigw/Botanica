import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum AppPermissionDecision {
  granted,
  provisional,
  limited,
  denied,
  permanentlyDenied,
  restricted,
}

class LocationPermissionSnapshot {
  const LocationPermissionSnapshot({
    required this.serviceEnabled,
    required this.decision,
  });

  final bool serviceEnabled;
  final AppPermissionDecision decision;

  bool get isUsable =>
      serviceEnabled && decision == AppPermissionDecision.granted;
}

class AppPermissionsSnapshot {
  const AppPermissionsSnapshot({
    required this.notifications,
    required this.location,
    required this.camera,
    required this.photos,
  });

  final AppPermissionDecision notifications;
  final LocationPermissionSnapshot location;
  final AppPermissionDecision camera;
  final AppPermissionDecision photos;
}

abstract interface class PermissionsService {
  Future<AppPermissionsSnapshot> snapshot();

  Future<AppPermissionDecision> requestNotifications();
  Future<LocationPermissionSnapshot> requestLocationWhenInUse();
  Future<AppPermissionDecision> requestCamera();
  Future<AppPermissionDecision> requestPhotos();

  Future<void> openSystemSettings();
}

class DefaultPermissionsService implements PermissionsService {
  const DefaultPermissionsService();

  @override
  Future<AppPermissionsSnapshot> snapshot() async {
    final notifications = _toDecision(await ph.Permission.notification.status);
    final camera = _toDecision(await ph.Permission.camera.status);
    final photos = _toDecision(await ph.Permission.photos.status);
    final location = await _locationSnapshot();

    return AppPermissionsSnapshot(
      notifications: notifications,
      location: location,
      camera: camera,
      photos: photos,
    );
  }

  @override
  Future<AppPermissionDecision> requestNotifications() async {
    final status = await ph.Permission.notification.request();
    return _toDecision(status);
  }

  @override
  Future<LocationPermissionSnapshot> requestLocationWhenInUse() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationPermissionSnapshot(
        serviceEnabled: false,
        decision: AppPermissionDecision.denied,
      );
    }

    final perm = await Geolocator.checkPermission();
    final resolved = perm == LocationPermission.denied
        ? await Geolocator.requestPermission()
        : perm;

    return LocationPermissionSnapshot(
      serviceEnabled: true,
      decision: _toLocationDecision(resolved),
    );
  }

  @override
  Future<AppPermissionDecision> requestCamera() async {
    final status = await ph.Permission.camera.request();
    return _toDecision(status);
  }

  @override
  Future<AppPermissionDecision> requestPhotos() async {
    final status = await ph.Permission.photos.request();
    return _toDecision(status);
  }

  @override
  Future<void> openSystemSettings() async {
    await ph.openAppSettings();
  }

  Future<LocationPermissionSnapshot> _locationSnapshot() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    final perm = await Geolocator.checkPermission();
    return LocationPermissionSnapshot(
      serviceEnabled: enabled,
      decision: _toLocationDecision(perm),
    );
  }
}

AppPermissionDecision _toDecision(ph.PermissionStatus status) {
  if (status.isGranted) {
    return AppPermissionDecision.granted;
  }
  if (status.isLimited) {
    return AppPermissionDecision.limited;
  }
  if (status.isProvisional) {
    return AppPermissionDecision.provisional;
  }
  if (status.isPermanentlyDenied) {
    return AppPermissionDecision.permanentlyDenied;
  }
  if (status.isRestricted) {
    return AppPermissionDecision.restricted;
  }
  return AppPermissionDecision.denied;
}

AppPermissionDecision _toLocationDecision(LocationPermission permission) {
  return switch (permission) {
    LocationPermission.always ||
    LocationPermission.whileInUse =>
      AppPermissionDecision.granted,
    LocationPermission.deniedForever => AppPermissionDecision.permanentlyDenied,
    LocationPermission.unableToDetermine => AppPermissionDecision.denied,
    LocationPermission.denied => AppPermissionDecision.denied,
  };
}
