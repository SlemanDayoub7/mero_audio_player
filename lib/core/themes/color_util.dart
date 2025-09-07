import 'package:flutter/material.dart';

class ColorUtil {
  // Generate two distinct colors from audio id using hash
  static List<Color> getGradientColorsFromId(String id) {
    final hash = id.codeUnits.fold(0, (prev, curr) => prev + curr);
    final hue1 = (hash * 37) % 360; // arbitrary multiplier to vary distribution
    final hue2 = (hash * 53) % 360; // different multiplier for second color

    Color colorFromHue(double hue) =>
        HSLColor.fromAHSL(1.0, hue, 0.6, 0.7).toColor();

    return [colorFromHue(hue1.toDouble()), colorFromHue(hue2.toDouble())];
  }
}
