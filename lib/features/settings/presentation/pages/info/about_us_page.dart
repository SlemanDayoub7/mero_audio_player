import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  void _launchUrl(String url) async {
    // Only prepend https if URL does not start with http or mailto
    if (!url.startsWith("http") && !url.startsWith("mailto:")) {
      url = "https://$url";
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          LocaleKeys.about_us_title.tr(),
          style: TextStyles.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AppGradientBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 90.h),

                /// Header
                Text(
                  LocaleKeys.about_us_header.tr(),
                  style: TextStyles.headlineLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 16.h),

                /// Intro
                Text(
                  LocaleKeys.about_us_intro.tr(),
                  style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 12.h),

                /// Mission
                Text(
                  LocaleKeys.about_us_mission_title.tr(),
                  style: TextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  LocaleKeys.about_us_mission.tr(),
                  style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 12.h),

                /// Features
                Text(
                  LocaleKeys.about_us_features_title.tr(),
                  style: TextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                ...[
                  LocaleKeys.about_us_features_point1.tr(),
                  LocaleKeys.about_us_features_point2.tr(),
                  LocaleKeys.about_us_features_point3.tr(),
                  LocaleKeys.about_us_features_point4.tr(),
                  LocaleKeys.about_us_features_point5.tr(),
                  LocaleKeys.about_us_features_point6.tr(),
                ].map(
                  (point) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      point,
                      style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                /// Contact
                Text(
                  LocaleKeys.about_us_contact_title.tr(),
                  style: TextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  LocaleKeys.about_us_contact.tr(),
                  style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 8.h),

                /// Social Links
                ListTile(
                  leading: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    LocaleKeys.contact_youtube.tr(),
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  onTap: () => _launchUrl(LocaleKeys.youtube_url.tr()),
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.blueAccent),
                  title: Text(
                    LocaleKeys.contact_linkedin.tr(),
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  onTap: () => _launchUrl(LocaleKeys.linkedin_url.tr()),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.send,
                    color: Colors.lightBlueAccent,
                  ),
                  title: Text(
                    LocaleKeys.contact_telegram.tr(),
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  onTap: () => _launchUrl(LocaleKeys.telegram_url.tr()),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.email,
                    color: Colors.lightBlueAccent,
                  ),
                  title: Text(
                    LocaleKeys.email.tr(),
                    style: TextStyles.bodyLarge.copyWith(
                      decoration: TextDecoration.underline,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  onTap: () => _launchUrl("mailto:${LocaleKeys.email.tr()}"),
                ),
                SizedBox(height: 8.h),

                // /// Email
                // SelectableText(
                //   LocaleKeys.email.tr(),
                //   style: TextStyles.bodyLarge.copyWith(
                //     decoration: TextDecoration.underline,
                //     color: Colors.lightBlueAccent,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
