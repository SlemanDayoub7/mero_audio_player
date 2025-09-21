import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'سياسة الخصوصية',
            style: TextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        backgroundColor: Colors.transparent, // خلفية سوداء للتماشي مع نص أبيض
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
                    'سياسة الخصوصية لتطبيق Mero Audio Player',
                    style: TextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'نحن في تطبيق Mero Audio Player نلتزم بحماية خصوصيتك وضمان أمان بياناتك أثناء استخدام التطبيق، وهو تطبيق شخصي مملوك لسليمان ديوب.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '1. المعلومات التي نجمعها',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '- لا يقوم التطبيق بجمع أية بيانات شخصية أو يشاركها مع جهات خارجية.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    '- يتم تخزين الملفات الصوتية، قوائم التشغيل، والكتب الصوتية على الذاكرة المحلية للجهاز فقط.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '2. استخدام البيانات المحلية',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '- تُستخدم البيانات المخزنة محليًا لتحسين تجربتك في استخدام التطبيق.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    '- لا يتم إرسال أو مشاركة أي من هذه البيانات عبر الإنترنت.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '3. الأذونات',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '- يطلب التطبيق أذونات للوصول إلى ملفات الصوت المحلية لتشغيلها فقط.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    '- لا يتم الوصول إلى أية بيانات أخرى دون إذن صريح.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '4. أمان البيانات',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '- البيانات محفوظة فقط على جهازك لتقليل مخاطر التعرض.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    '- ننصح بتأمين جهازك باستخدام كلمات مرور قوية للحفاظ على خصوصيتك.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '5. حقوق المستخدم',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '- يمكن للمستخدم حذف أو تعديل بياناته المحلية في أي وقت.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    '- يمكن للمستخدم إلغاء أذونات التطبيق من إعدادات الجهاز.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '6. التواصل',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لأي استفسار حول سياسة الخصوصية، يرجى التواصل عبر البريد الإلكتروني التالي:',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 4.h),
                  SelectableText(
                    'slemandayoub77@gmail.com',
                    style: TextStyles.bodyLarge.copyWith(
                      decoration: TextDecoration.underline,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '7. تحديثات سياسة الخصوصية',
                    style: TextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '- قد يتم تحديث هذه السياسة بين فترة وأخرى لضمان الامتثال للتشريعات الحديثة وتحسين إجراءات الخصوصية.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    '- سيتم إعلام المستخدم بأي تغييرات جوهرية في السياسة.',
                    style: TextStyles.bodyLarge.copyWith(color: Colors.white),
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
