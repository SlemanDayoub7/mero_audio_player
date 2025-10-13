import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive, HiveX;
import 'package:media_store_plus/media_store_plus.dart';

import 'package:mero_audio_player/core/constants/app_constants.dart';
import 'package:mero_audio_player/core/constants/hive_boxes.dart';

import 'package:mero_audio_player/core/localization/languages.dart';
import 'package:mero_audio_player/core/localization/locale_cubit.dart';
import 'package:mero_audio_player/features/splash/splash_page.dart';
import 'package:mero_audio_player/gen/fonts.gen.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'core/di/injection.dart';

final MediaStore mediaStore = MediaStore();
Completer<bool>? permissionCompleter;

bool ok = false;
final OnAudioQuery audioQuery = OnAudioQuery();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ui.DartPluginRegistrant.ensureInitialized();
  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
  }

  final sdk = await mediaStore.getPlatformSDKInt();
  List<Permission> permissions = [Permission.storage];
  if (sdk >= 33) {
    permissions.add(Permission.audio);
  }
  await permissions.request();

  MediaStore.appFolder = "MeroAudioPlayer";
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();

  var box = await Hive.openBox(HiveBoxes.settings);
  String? savedLangCode = box.get(HiveBoxes.locale);

  runApp(
    EasyLocalization(
      startLocale:
          savedLangCode != null
              ? Locale(savedLangCode)
              : Locale(ui.window.locale.languageCode),
      fallbackLocale: Languages.en.locale,
      path: AppConstants.assetsLocalesPath,
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // if (state == AppLifecycleState.detached) {
    //   await Injection.audioHandler.stop();
    // }
    if (state == AppLifecycleState.resumed &&
        permissionCompleter != null &&
        !permissionCompleter!.isCompleted) {
      RingtoneSet.isWriteSettingsGranted.then((granted) {
        permissionCompleter?.complete(granted);
        permissionCompleter = null;
      });
    }
  }

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
                  theme: ThemeData(fontFamily: FontFamily.changa),
                  home: SplashPage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
