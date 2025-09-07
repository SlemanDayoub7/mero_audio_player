import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      fontFamily: "Changa",
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,

        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: "Changa",
          color: Colors.white,
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(color: Colors.white, fontSize: 16.sp),
        bodyMedium: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14.sp,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Colors.white70,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      iconTheme: IconThemeData(color: Colors.white),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blueGrey,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.blueGrey.shade900,
        hintStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
        labelStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
      cardColor: Colors.blueGrey.shade900,
      dividerColor: Colors.white24,
      colorScheme: ColorScheme.dark(
        primary: Colors.blueGrey,
        secondary: Colors.lightBlueAccent,
        background: Colors.black,
        surface: Colors.blueGrey.shade900,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
