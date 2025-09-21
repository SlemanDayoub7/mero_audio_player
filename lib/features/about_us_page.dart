import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'من نحن',
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
                  Text(
                    'تطبيق Mero Audio Player',
                    style: TextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'مرحبًا بكم في تطبيق Mero Audio Player، تطبيق صوتيات شخصي يهدف إلى توفير أفضل تجربة لتشغيل الملفات الصوتية والكتب الصوتية بجودة عالية وسهولة استخدام.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'تم تطوير هذا التطبيق بواسطة سليمان ديوب، طالب في السنة الخامسة في هندسة المعلوماتية في جامعة حمص، يهدف من خلاله إلى توفير أداة عملية ومفيدة تسمح للمستخدمين بالتحكم الكامل في ملفاتهم الصوتية وقوائم التشغيل بشكل مباشر على أجهزتهم.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'نحن نسعى دائمًا لتطوير التطبيق وتحسينه من خلال الاستماع لملاحظات المستخدمين وتوفير تحديثات دورية لتحسين الأداء وزيادة الميزات.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'إذا كانت لديكم أي اقتراحات أو استفسارات، فلا تترددوا في التواصل معنا عبر البريد الإلكتروني المدون في صفحة سياسة الخصوصية.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: Text(
                      'شكراً لاستخدامكم Mero Audio Player!',
                      style: TextStyles.headlineMedium.copyWith(
                        color: Colors.white,
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
