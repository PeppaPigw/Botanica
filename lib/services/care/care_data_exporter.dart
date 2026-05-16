import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/care_log.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';

class CareDataExporter {
  static Future<bool> export({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
  }) async {
    if (plants.isEmpty) return false;

    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
      'plants': plants.map((p) => p.toJson()).toList(),
      'careLogs': logs.map((l) => l.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/botanica_export_$timestamp.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Botanica Care Data',
    );

    return true;
  }
}
