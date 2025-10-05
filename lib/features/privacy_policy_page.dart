import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          LocaleKeys.privacyPolicy.tr(),
          style: TextStyles.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AppGradientBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 90.h),

                /// العنوان الرئيسي
                Text(
                  LocaleKeys.privacy_policy_header.tr(),
                  style: TextStyles.headlineLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 16.h),

                /// المقدمة
                Text(
                  LocaleKeys.privacy_policy_intro.tr(),
                  style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                SizedBox(height: 12.h),

                /// القسم 1
                _buildSection(
                  title: LocaleKeys.section1_title.tr(),
                  points: [
                    LocaleKeys.section1_point1.tr(),
                    LocaleKeys.section1_point2.tr(),
                  ],
                ),

                /// القسم 2
                _buildSection(
                  title: LocaleKeys.section2_title.tr(),
                  points: [
                    LocaleKeys.section2_point1.tr(),
                    LocaleKeys.section2_point2.tr(),
                  ],
                ),

                /// القسم 3
                _buildSection(
                  title: LocaleKeys.section3_title.tr(),
                  points: [
                    LocaleKeys.section3_point1.tr(),
                    LocaleKeys.section3_point2.tr(),
                  ],
                ),

                /// القسم 4
                _buildSection(
                  title: LocaleKeys.section4_title.tr(),
                  points: [
                    LocaleKeys.section4_point1.tr(),
                    LocaleKeys.section4_point2.tr(),
                  ],
                ),

                /// القسم 5
                _buildSection(
                  title: LocaleKeys.section5_title.tr(),
                  points: [
                    LocaleKeys.section5_point1.tr(),
                    LocaleKeys.section5_point2.tr(),
                  ],
                ),

                /// القسم 6 (التواصل)
                // Text(
                //   LocaleKeys.section6_title.tr(),
                //   style: TextStyles.headlineMedium.copyWith(
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //   ),
                // ),
                // SizedBox(height: 8.h),
                // Text(
                //   LocaleKeys.section6_point1.tr(),
                //   style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                // ),
                // SizedBox(height: 4.h),
                // SelectableText(
                //   LocaleKeys.email.tr(),
                //   style: TextStyles.bodyLarge.copyWith(
                //     decoration: TextDecoration.underline,
                //     color: Colors.lightBlueAccent,
                //   ),
                // ),
                // SizedBox(height: 12.h),

                // /// القسم 7 (التحديثات)
                // _buildSection(
                //   title: LocaleKeys.section7_title.tr(),
                //   points: [
                //     LocaleKeys.section7_point1.tr(),
                //     LocaleKeys.section7_point2.tr(),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> points}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          ...points.map(
            (p) => Text(
              p,
              style: TextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
