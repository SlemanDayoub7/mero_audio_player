import 'package:flutter/material.dart';
import 'package:mero_audio_player/core/app_startup.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupApp();
  runApp(const MyApp());
}
