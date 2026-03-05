import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap.dart';
import 'app/botanica_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BotanicaBootstrap.initialize();

  runApp(
    const ProviderScope(
      child: BotanicaApp(),
    ),
  );
}
