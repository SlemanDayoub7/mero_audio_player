import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ColorSchemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension PaddingExtension on BuildContext {
  EdgeInsets get paddingLow => EdgeInsets.all(8.r);
  EdgeInsets get paddingMedium => EdgeInsets.all(16.r);
  EdgeInsets get paddingHigh => EdgeInsets.all(32.r);
}

extension SizedBoxExtension on BuildContext {
  SizedBox get emptySizedWidthLow => SizedBox(width: 8.w);
  SizedBox get emptySizedWidthMedium => SizedBox(width: 16.w);
  SizedBox get emptySizedWidthHigh => SizedBox(width: 32.w);

  SizedBox get emptySizedHeightLow => SizedBox(height: 8.h);
  SizedBox get emptySizedHeightMedium => SizedBox(height: 16.h);
  SizedBox get emptySizedHeightHigh => SizedBox(height: 32.h);
}

extension ThemeDataExtension on ThemeData {
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get secondary => colorScheme.secondary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get background => colorScheme.background;
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
}

extension TextStyleExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get overline => copyWith(decoration: TextDecoration.overline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  TextStyle size(double newSize) => copyWith(fontSize: newSize);
  TextStyle color(Color newColor) => copyWith(color: newColor);
}

extension IconThemeDataExtension on IconThemeData {
  IconThemeData size(double newSize) => copyWith(size: newSize);
  IconThemeData color(Color newColor) => copyWith(color: newColor);
}
