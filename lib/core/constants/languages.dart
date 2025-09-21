import 'dart:ui';

import 'package:equatable/equatable.dart';

// import '../../../gen/assets.gen.dart';

class Languages extends Equatable {
  static const english = Languages._(
      locale: Locale('en'),
      code: 'en',
      displayName: 'English',
      // image: Assets.images.languages.englishFlag
  );
  static const arabic = Languages._(
      locale: Locale('ar'),
      code: 'ar',
      displayName: 'عربي',
      // image: Assets.images.languages.arabicFlag
  );
  static final list = [
    english,
    arabic,
  ];

  const Languages._(
      {required this.code,
      required this.locale,
      required this.displayName,
      // required this.image
      });

  final String code;
  final Locale locale;
  final String displayName;
  // final AssetGenImage image;

  @override
  List<Object?> get props => [code];
}
