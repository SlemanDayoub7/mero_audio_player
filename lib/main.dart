import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;

import 'package:mero_audio_player/core/constants/app_constants.dart';
import 'package:mero_audio_player/core/constants/languages.dart';
import 'package:mero_audio_player/core/locale_cubit.dart';

import 'package:mero_audio_player/main_screen.dart';
import 'package:mero_audio_player/permission_request_page.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'injection.dart';

bool ok = false;
final OnAudioQuery audioQuery = OnAudioQuery();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitDown,
  //   DeviceOrientation.portraitUp,
  // ]);
  // Initialize dependencies
  await EasyLocalization.ensureInitialized();
  ok = await audioQuery.permissionsStatus();
  await Injection.init();
  var box = await Hive.openBox('settings');
  String? savedLangCode = box.get('locale');

  runApp(
    EasyLocalization(
      startLocale:
          savedLangCode != null
              ? Locale(savedLangCode)
              : Locale(ui.window.locale.languageCode),
      fallbackLocale: Languages.arabic.locale,
      path: 'assets/locales',
      supportedLocales: Languages.list.map((e) => e.locale).toList(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: Injection.getProviders(context),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 0.75),
            child: ScreenUtilInit(
              designSize: const Size(402, 874),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.appTitle,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  locale: locale,
                  theme: ThemeData(fontFamily: 'Changa'),

                  //   supportedLocales: [Locale('ar')],
                  home: !ok ? PermissionRequestPage() : MainScreen(),
                  // routes: {
                  //   '/home': (context) => MainScreen(), // صفحتك الرئيسية بعد الموافقة
                  // },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
