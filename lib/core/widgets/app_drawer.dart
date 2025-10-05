import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/core/constants/languages.dart';

import 'package:mero_audio_player/core/themes/text_styles.dart';

import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class AppDrawer extends StatelessWidget {
  final Function()? onChangeBackground;
  final Function()? onChangeLanguage;
  final Function()? onPrivacyPolicy;
  final Function()? onAboutUs;

  const AppDrawer({
    Key? key,
    this.onChangeBackground,
    this.onChangeLanguage,
    this.onPrivacyPolicy,
    this.onAboutUs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: 0.8.sw,
        decoration: BoxDecoration(
          color: globalBackgroundColor,
          // gradient: gradientFromColor(globalBackgroundColor ?? Colors.black),
        ), // You can change this to any dark bg color
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Column(
          spacing: 20.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: Assets.images.logo.image(width: 100.w, height: 100.w),
                ),
                Text(
                  'Mero Audio Player',
                  style: TextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10.h), CompactLanguageDropdown(),
            // LanguageSwitcher(
            //   isEnglishSelected: context.locale.languageCode == 'en',
            //   onChanged: (selected) async {
            //     final newLocale =
            //         context.locale.languageCode == 'ar'
            //             ? const Locale('en')
            //             : const Locale('ar');
            //     context.setLocale(newLocale);
            //     context.read<LocaleCubit>().changeLocale(newLocale);
            //     var box = await Hive.openBox('settings');
            //     await box.put('locale', newLocale.languageCode);
            //     context.read<PlaylistBloc>().add(LoadPlaylists());
            //     context.read<ArtistListBloc>().add(FetchArtistList());
            //     context.read<AudioListBloc>().add(FetchAudioList());
            //     context.read<AlbumListBloc>().add(FetchAlbumList());
            //     Navigator.of(context).pushReplacement(
            //       MaterialPageRoute(builder: (context) => MainScreen()),
            //     );

            //     // context.router.pushAndPopUntil(
            //     //   SplashRoute(),
            //     //   predicate: (route) => false,
            //     // );
            //     // context.read<AuthBloc>().add(GetLoggedUser());
            //   },
            // ),
            InkWell(
              onTap: onChangeBackground,
              child: Row(
                children: [
                  Icon(Icons.format_paint, size: 24.sp, color: Colors.white),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      LocaleKeys.changeBackground.tr(),
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ListTile(
            //   leading: Icon(Icons.language, size: 24.sp, color: Colors.white),
            //   title: Text(
            //     "تغيير اللغة",
            //     style: TextStyles.titleLarge.copyWith(color: Colors.white),
            //   ),
            //   onTap: onChangeLanguage,
            // ),
            InkWell(
              onTap: onPrivacyPolicy,
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, size: 24.sp, color: Colors.white),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      LocaleKeys.privacyPolicy.tr(),
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onAboutUs,
              child: Row(
                children: [
                  Icon(Icons.info, size: 24.sp, color: Colors.white),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      LocaleKeys.aboutUs.tr(),
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
