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
import 'package:mero_audio_player/core/constants/languages.dart';
import 'package:mero_audio_player/core/locale_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/splash/splash_screen.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'injection.dart';

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

  // اطلب الصلاحيات
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
  // Initialize dependencies
  await EasyLocalization.ensureInitialized();
  // ok = await audioQuery.permissionsStatus();
  // await Injection.init();
  // Initialize Hive
  await Hive.initFlutter();

  var box = await Hive.openBox('settings');
  String? savedLangCode = box.get('locale');

  runApp(
    EasyLocalization(
      startLocale:
          savedLangCode != null
              ? Locale(savedLangCode)
              : Locale(ui.window.locale.languageCode),
      fallbackLocale: Languages.en.locale,
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
    // التطبيق خرج من الواجهة (swipe away أو الخلفية)
    // if (state == AppLifecycleState.detached) {
    //   await Injection.audioHandler.stop(); // يوقف كل شيء ويزيل الإشعار
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
                  theme: ThemeData(fontFamily: 'Changa'),
                  home: SplashScreen(),
                  // !ok ? PermissionRequestPage() : MainScreen(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
