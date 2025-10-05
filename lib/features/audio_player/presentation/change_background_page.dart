import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/main_screen.dart';

// Helpers
LinearGradient gradientFromColor(Color color) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    color.withOpacity(0.9),
    color.withOpacity(0.6),
    color.withOpacity(0.3),
  ],
);
LinearGradient gradientFromColorTwo(Color color) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [color.withOpacity(0.3), color.withOpacity(0.8)],
);
const String backgroundBoxName = 'backgroundBox';
const String backgroundColorKey = 'backgroundColor';
const String backgroundImageKey = 'backgroundImagePath';
const String lottieKey = 'selectedLottie';

Color? globalBackgroundColor;
String? globalBackgroundImagePath;
String globalLottiePath = 'assets/lottie/Decent Soundwaves white.json';

class ChangeBackgroundPage extends StatefulWidget {
  @override
  _ChangeBackgroundPageState createState() => _ChangeBackgroundPageState();
}

class _ChangeBackgroundPageState extends State<ChangeBackgroundPage> {
  late Box backgroundBox;

  final List<Color> colors = [
    Color(0xFF121212),
    Color(0xFF003366),
    Color(0xFF004225),
    Color(0xFF8B0000),
    Color(0xFF4B0082),
    Color(0xFFCC5500),
    Color(0xFF555500),
    Color(0xFF660099),
  ];

  List<String> bgImages = ['assets/images/mate.png'];

  final List<String> lottieAssets = [
    'assets/lottie/Decent Soundwaves.json',
    'assets/lottie/Sound Animation.json',
    'assets/lottie/Decent Soundwaves white.json',
  ];

  Color? selectedColor;
  String? selectedImage;
  File? selectedDeviceImage;
  String selectedLottie = 'assets/lottie/Decent Soundwaves white.json';

  @override
  void initState() {
    super.initState();
    backgroundBox = Hive.box(backgroundBoxName);

    int? savedColorValue = backgroundBox.get(backgroundColorKey);
    String? savedImage = backgroundBox.get(backgroundImageKey);
    String? savedLottie = backgroundBox.get(lottieKey);

    if (savedLottie != null) selectedLottie = savedLottie;
    if (savedColorValue != null)
      selectedColor = Color(savedColorValue);
    else
      selectedColor = colors[0];

    if (savedImage != null && savedImage.isNotEmpty) {
      selectedImage = savedImage;
      if (!savedImage.contains('assets')) bgImages.add(savedImage);
    } else {
      selectedImage = globalBackgroundImagePath;
    }
  }

  void saveSelection() async {
    if (selectedColor != null)
      await backgroundBox.put(backgroundColorKey, selectedColor!.value);

    if (selectedImage != null)
      await backgroundBox.put(backgroundImageKey, selectedImage);

    await backgroundBox.put(lottieKey, selectedLottie);

    globalBackgroundColor = selectedColor ?? Colors.black;
    globalBackgroundImagePath = selectedImage;
    globalLottiePath = selectedLottie;
  }

  void toggleColor(Color color) {
    setState(() {
      selectedColor = color;
    });
    saveSelection(); // حفظ تلقائي عند اختيار اللون
  }

  void toggleImage(String path) {
    setState(() {
      selectedImage = path;
    });
    saveSelection(); // حفظ تلقائي عند اختيار الصورة
  }

  void toggleLottie(String asset) {
    setState(() {
      selectedLottie = asset;
    });
    saveSelection(); // حفظ تلقائي عند اختيار Lottie
  }

  Future<void> pickDeviceImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedDeviceImage = File(image.path);
        selectedImage = selectedDeviceImage?.path ?? '';
        bgImages.add(selectedImage!);
      });
      saveSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        saveSelection();
        context.read<PlaylistBloc>().add(LoadPlaylists());
        context.read<ArtistListBloc>().add(FetchArtistList());
        context.read<AudioListBloc>().add(FetchAudioList());
        context.read<AlbumListBloc>().add(FetchAlbumList());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
        return Future.value(true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            LocaleKeys.changeBackground.tr(),
            style: TextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image:
                selectedImage != null
                    ? DecorationImage(
                      image:
                          selectedImage!.contains('assets')
                              ? AssetImage(selectedImage!)
                              : FileImage(File(selectedImage!))
                                  as ImageProvider,
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradientFromColor(selectedColor ?? Colors.black),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100.h),
                  _buildSectionTitle(LocaleKeys.selectColor.tr()),
                  SizedBox(height: 12.h),
                  _buildColorPicker(),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(LocaleKeys.selectImage.tr()),
                  SizedBox(height: 12.h),
                  _buildImageGrid(),
                  SizedBox(height: 16.h),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: pickDeviceImage,
                      icon: Icon(Icons.photo_library, color: Colors.white),
                      label: Text(
                        LocaleKeys.selectImageFromDevice.tr(),
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(LocaleKeys.select_player_background.tr()),
                  SizedBox(height: 12.h),
                  _buildLottiePicker(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: TextStyles.headlineLarge.copyWith(color: Colors.white),
  );

  Widget _buildColorPicker() => Wrap(
    spacing: 12.w,
    runSpacing: 12.h,
    children:
        colors
            .map(
              (color) => GestureDetector(
                onTap: () => toggleColor(color),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          selectedColor == color
                              ? Colors.blueAccent
                              : Colors.grey,
                      width: 3.w,
                    ),
                  ),
                  child:
                      selectedColor == color
                          ? Icon(Icons.check, color: Colors.white, size: 24.sp)
                          : null,
                ),
              ),
            )
            .toList(),
  );

  Widget _buildImageGrid() => GridView.builder(
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
    ),
    itemCount: bgImages.length,
    itemBuilder: (_, index) {
      final path = bgImages[index];
      final isSelected = selectedImage == path;
      return GestureDetector(
        onTap: () => toggleImage(path),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child:
                  path.contains('assets')
                      ? Image.asset(path, fit: BoxFit.cover)
                      : Image.file(File(path), fit: BoxFit.cover),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blueAccent, width: 4.w),
                  color: Colors.black26,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blueAccent,
                    size: 30.sp,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _buildLottiePicker() => Wrap(
    spacing: 12.w,
    children:
        lottieAssets
            .map(
              (asset) => GestureDetector(
                onTap: () => toggleLottie(asset),
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          selectedLottie == asset
                              ? Colors.blueAccent
                              : Colors.transparent,
                      width: 3.w,
                    ),
                  ),
                  child: Center(child: Lottie.asset(asset)),
                ),
              ),
            )
            .toList(),
  );
}
