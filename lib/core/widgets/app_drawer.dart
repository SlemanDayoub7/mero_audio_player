import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import 'package:mero_audio_player/core/locale_cubit.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';

import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/main_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function()? onChangeBackground;
  final Function()? onChangeLanguage;
  final Function()? onPrivacyPolicy;
  final Function()? onHowAreWe;

  const AppDrawer({
    Key? key,
    this.onChangeBackground,
    this.onChangeLanguage,
    this.onPrivacyPolicy,
    this.onHowAreWe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: globalBackgroundColor,
          // gradient: gradientFromColor(globalBackgroundColor ?? Colors.black),
        ), // You can change this to any dark bg color
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            LanguageSwitcher(
              isEnglishSelected: context.locale.languageCode == 'en',
              onChanged: (selected) async {
                final newLocale =
                    context.locale.languageCode == 'ar'
                        ? const Locale('en')
                        : const Locale('ar');
                context.setLocale(newLocale);
                context.read<LocaleCubit>().changeLocale(newLocale);
                var box = await Hive.openBox('settings');
                await box.put('locale', newLocale.languageCode);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );

                // context.router.pushAndPopUntil(
                //   SplashRoute(),
                //   predicate: (route) => false,
                // );
                // context.read<AuthBloc>().add(GetLoggedUser());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.format_paint,
                size: 24.sp,
                color: Colors.white,
              ),
              title: Text(
                LocaleKeys.changeBackground.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
              onTap: onChangeBackground,
            ),

            // ListTile(
            //   leading: Icon(Icons.language, size: 24.sp, color: Colors.white),
            //   title: Text(
            //     "تغيير اللغة",
            //     style: TextStyles.titleLarge.copyWith(color: Colors.white),
            //   ),
            //   onTap: onChangeLanguage,
            // ),
            ListTile(
              leading: Icon(
                Icons.privacy_tip,
                size: 24.sp,
                color: Colors.white,
              ),
              title: Text(
                LocaleKeys.privacyPolicy.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
              onTap: onPrivacyPolicy,
            ),
            ListTile(
              leading: Icon(Icons.info, size: 24.sp, color: Colors.white),
              title: Text(
                LocaleKeys.aboutUs.tr(),
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
              onTap: onHowAreWe,
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Text(
                "© 2025 SLEMAN DAYOYB",
                style: TextStyles.displayMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageSwitcher extends StatelessWidget {
  final bool isEnglishSelected;
  final Function(bool) onChanged;

  const LanguageSwitcher({
    super.key,
    required this.isEnglishSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170.w,
      height: 60.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: globalBackgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              height: 60.h,
              width: 80.w,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:
                    !isEnglishSelected
                        ? Colors.white.withOpacity(0.7)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: Text(
                  'العربية',
                  style: TextStyles.bodyMedium.copyWith(
                    color: !isEnglishSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              width: 80.w,
              height: 60.h,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isEnglishSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  'EN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
