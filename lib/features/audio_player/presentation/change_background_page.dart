import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';

import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/main_screen.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

// Helper to create a gradient from a base color
LinearGradient gradientFromColor(Color color) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      color.withOpacity(0.9), // Slightly transparent base color
      color.withOpacity(0.6), // More transparent for gradient end
      color.withOpacity(0.3),
    ],
  );
}

LinearGradient gradientFromColorTwo(Color color) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      color.withOpacity(0.3), // Slightly transparent base color
      color.withOpacity(0.7), // More transparent for gradient end
      color.withOpacity(0.8),
    ],
  );
}

// Define keys for Hive storage
const String backgroundBoxName = 'backgroundBox';
const String backgroundColorKey = 'backgroundColor';
const String backgroundImageKey = 'backgroundImagePath';

// Global variables to hold current background state
Color? globalBackgroundColor;
String? globalBackgroundImagePath;

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

  List<String> bgImages = [
    'assets/images/bg_one.jpg',
    'assets/images/bg_two.jpg',
    'assets/images/bg_three.jpg',
    'assets/images/bg_four.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
    'assets/images/7.jpg',
    'assets/images/8.jpg',
    'assets/images/9.jpg',
    'assets/images/10.jpg',
  ];

  Color? selectedColor;
  String? selectedImage;
  File? selectedDeviceImage;

  @override
  void initState() {
    super.initState();
    backgroundBox = Hive.box(backgroundBoxName);

    int? savedColorValue = backgroundBox.get(backgroundColorKey);
    String? savedImage = backgroundBox.get(backgroundImageKey);

    if (savedColorValue != null) {
      selectedColor = Color(savedColorValue);
    } else {
      selectedColor = colors[0];
    }

    if (savedImage != null && savedImage.isNotEmpty) {
      selectedImage = savedImage;
      if (!savedImage.contains('assets') && savedImage != '')
        bgImages.add(savedImage);
    }
  }

  void toggleColorSelection(Color color) {
    setState(() {
      if (selectedColor == color) {
        selectedColor = null; // إلغاء التحديد إذا تم الضغط على اللون المختار
      } else {
        selectedColor = color; // اختيار اللون الجديد
      }
    });
  }

  void toggleImageSelection(String imagePath) {
    setState(() {
      if (selectedImage == imagePath) {
        selectedImage = null; // إلغاء التحديد إذا تم الضغط على الصورة المختارة
      } else {
        selectedImage = imagePath; // اختيار الصورة الجديدة
      }
    });
  }

  Future<void> pickImageFromDevice() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedDeviceImage = File(image.path);
        selectedImage = selectedDeviceImage?.path ?? '';
      });
    }
  }

  void saveSelection() async {
    if (selectedColor != null) {
      await backgroundBox.put(backgroundColorKey, selectedColor!.value);
    } else {
      await backgroundBox.delete(backgroundColorKey);
    }
    if (selectedImage != null) {
      await backgroundBox.put(backgroundImageKey, selectedImage);
    } else {
      await backgroundBox.delete(backgroundImageKey);
    }
    globalBackgroundImagePath = selectedImage;
    globalBackgroundColor = selectedColor ?? Colors.black;

    // الانتقال إلى الصفحة الرئيسية بعد الحفظ
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          image: DecorationImage(
            image:
                (selectedImage ?? '').contains('assets')
                    ? AssetImage(selectedImage ?? '')
                    : FileImage(File(selectedImage ?? '')),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: gradientFromColor(selectedColor ?? Colors.black),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 90.h),
                  Text(
                    'اختر لون',
                    style: TextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children:
                        colors.map((color) {
                          final bool isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () => toggleColorSelection(color),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.blueAccent
                                              : Colors.grey,
                                      width: 3.w,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'اختر صورة',
                    style: TextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                    ),
                    itemCount: bgImages.length,
                    itemBuilder: (context, index) {
                      final path = bgImages[index];
                      final bool isSelected = selectedImage == path;
                      return GestureDetector(
                        onTap: () => toggleImageSelection(path),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child:
                                  path.contains('assets')
                                      ? Image.asset(path, fit: BoxFit.cover)
                                      : Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            if (isSelected)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 4.w,
                                  ),
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
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: pickImageFromDevice,
                      icon: Icon(Icons.photo_library, color: Colors.white),
                      label: Text(
                        'اختر صورة من الجهاز',
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
                  SizedBox(height: 32.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: saveSelection,
                      child: Text(
                        'حفظ',
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor ?? Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 36.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
