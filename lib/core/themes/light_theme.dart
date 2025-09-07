import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      fontFamily: "Changa",
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: "Changa",
          color: Colors.black,
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: Colors.black.withOpacity(0.6),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Colors.black,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Colors.black54,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      iconTheme: IconThemeData(color: Colors.black87),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade200,
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
        labelStyle: TextStyle(color: Colors.black87, fontSize: 16.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade300,
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.lightBlueAccent,
        background: Colors.white,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onBackground: Colors.black,
        onSurface: Colors.black87,
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
