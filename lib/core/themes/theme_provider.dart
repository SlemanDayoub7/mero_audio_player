import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mero_audio_player/core/themes/models/theme_model.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _boxName = 'themeBox';
  static const String _key = 'theme';

  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  ThemeData get themeData => _themeData;

  Future<void> setSeedColor(Color color) async {
    _themeData = ThemeData(
      fontFamily: "Changa",

      colorScheme: ColorScheme.fromSeed(seedColor: color),
      useMaterial3: true,
    );
    notifyListeners();

    final box = await Hive.openBox<ThemeModel>(_boxName);
    await box.put(_key, ThemeModel(color.value));
  }

  static Future<ThemeNotifier> load() async {
    final box = await Hive.openBox<ThemeModel>(_boxName);
    final saved = box.get(_key);
    final seedColor = saved?.color ?? Colors.deepPurple;

    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      useMaterial3: true,

      fontFamily: "Changa",
    );

    return ThemeNotifier(theme);
  }
}
