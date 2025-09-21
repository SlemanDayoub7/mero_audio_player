import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
  // Display
  static final TextStyle displayLarge = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle displayMedium = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle displaySmall = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
  );

  // Headline
  static final TextStyle headlineLarge = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle headlineMedium = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle headlineSmall = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
  );

  // Title
  static final TextStyle titleLarge = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle titleMedium = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle titleSmall = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
  );

  // Body
  static final TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  // Label
  static final TextStyle labelLarge = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle labelSmall = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
  );

  // TextTheme جاهزة إذا حابب تستخدمها مع ThemeData
  static final TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
