import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_model.g.dart';

@HiveType(typeId: 0)
class ThemeModel {
  @HiveField(0)
  final int seedColor; // نخزن اللون كـ int

  ThemeModel(this.seedColor);

  Color get color => Color(seedColor);
}
