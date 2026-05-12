import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppLogger with WidgetsBindingObserver {
  AppLogger._();

  static final AppLogger instance = AppLogger._();
  static const int _maxBytes = 1024 * 1024;

  File? _file;
  Future<void> _pending = Future<void>.value();
  bool _initialized = false;
  FlutterExceptionHandler? _previousFlutterError;
  ErrorCallback? _previousPlatformError;

  static Future<void> initialize() => instance._initialize();

  static Future<void> info(String event, [String? message]) {
    return instance._write('info', event, message);
  }

  static Future<void> warning(String event, [String? message]) {
    return instance._write('warning', event, message);
  }

  static Future<void> error(
    String event,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return instance._write(
      'error',
      event,
      '$error${stackTrace == null ? '' : '\n$stackTrace'}',
    );
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationSupportDirectory();
      final logDir = Directory(p.join(dir.path, 'logs'));
      await logDir.create(recursive: true);
      _file = File(p.join(logDir.path, 'botanica.log'));
      await _rotateIfNeeded();
    } catch (_) {
      _file = null;
    }
    _installErrorHandlers();
    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
    await _write('info', 'app_start');
  }

  void _installErrorHandlers() {
    _previousFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(error('flutter_error', details.exception, details.stack));
      final previous = _previousFlutterError;
      if (previous != null) {
        previous(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    _previousPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(AppLogger.error('platform_error', error, stack));
      return _previousPlatformError?.call(error, stack) ?? false;
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_write('info', 'lifecycle_${state.name}'));
  }

  Future<void> _write(String level, String event, [String? message]) {
    _pending = _pending.then((_) async {
      final file = _file;
      if (file == null) return;
      try {
        await _rotateIfNeeded();
        final timestamp = DateTime.now().toUtc().toIso8601String();
        final body = message == null ? '' : ' ${_singleLine(message)}';
        await file.writeAsString(
          '$timestamp $level $event$body\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (_) {
        return;
      }
    });
    return _pending;
  }

  Future<void> _rotateIfNeeded() async {
    final file = _file;
    if (file == null) return;
    if (!await file.exists()) return;
    final length = await file.length();
    if (length < _maxBytes) return;
    final rotated = File('${file.path}.1');
    if (await rotated.exists()) {
      await rotated.delete();
    }
    await file.rename(rotated.path);
  }

  String _singleLine(String value) {
    return value
        .replaceAll('\r', r'\r')
        .replaceAll('\n', r'\n')
        .trim();
  }
}
