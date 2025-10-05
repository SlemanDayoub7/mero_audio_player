import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/locale_cubit.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/gen/fonts.gen.dart';
import 'package:mero_audio_player/main_screen.dart';

// import '../../../gen/assets.gen.dart';

class Languages extends Equatable {
  static const afr = Languages._(
    locale: Locale('af'),
    code: 'af',
    displayName: 'Afrikaans',
  );

  static const am = Languages._(
    locale: Locale('am'),
    code: 'am',
    displayName: 'አማርኛ',
  );

  static const hy = Languages._(
    locale: Locale('hy'),
    code: 'hy',
    displayName: 'հայերեն',
  );

  static const be = Languages._(
    locale: Locale('be'),
    code: 'be',
    displayName: 'беларуская',
  );

  static const bg = Languages._(
    locale: Locale('bg'),
    code: 'bg',
    displayName: 'български',
  );

  static const ca = Languages._(
    locale: Locale('ca'),
    code: 'ca',
    displayName: 'català',
  );

  static const zh = Languages._(
    locale: Locale('zh'),
    code: 'zh',
    displayName: '中文',
  );

  static const hr = Languages._(
    locale: Locale('hr'),
    code: 'hr',
    displayName: 'hrvatski',
  );

  static const cs = Languages._(
    locale: Locale('cs'),
    code: 'cs',
    displayName: 'čeština',
  );

  static const da = Languages._(
    locale: Locale('da'),
    code: 'da',
    displayName: 'dansk',
  );

  static const nl = Languages._(
    locale: Locale('nl'),
    code: 'nl',
    displayName: 'Nederlands',
  );

  static const en = Languages._(
    locale: Locale('en'),
    code: 'en',
    displayName: 'English',
  );

  static const et = Languages._(
    locale: Locale('et'),
    code: 'et',
    displayName: 'eesti keel',
  );

  static const fa = Languages._(
    locale: Locale('fa'),
    code: 'fa',
    displayName: 'فارسی',
  );

  static const fi = Languages._(
    locale: Locale('fi'),
    code: 'fi',
    displayName: 'suomi',
  );

  static const fr = Languages._(
    locale: Locale('fr'),
    code: 'fr',
    displayName: 'français',
  );

  static const de = Languages._(
    locale: Locale('de'),
    code: 'de',
    displayName: 'Deutsch',
  );

  static const el = Languages._(
    locale: Locale('el'),
    code: 'el',
    displayName: 'Ελληνικά',
  );

  static const he = Languages._(
    locale: Locale('he'),
    code: 'he',
    displayName: 'עברית',
  );

  static const hi = Languages._(
    locale: Locale('hi'),
    code: 'hi',
    displayName: 'हिन्दी',
  );

  static const hu = Languages._(
    locale: Locale('hu'),
    code: 'hu',
    displayName: 'magyar',
  );

  static const isl = Languages._(
    locale: Locale('is'),
    code: 'is',
    displayName: 'íslenska',
  );

  static const id = Languages._(
    locale: Locale('id'),
    code: 'id',
    displayName: 'Bahasa Indonesia',
  );

  static const it = Languages._(
    locale: Locale('it'),
    code: 'it',
    displayName: 'italiano',
  );

  static const ja = Languages._(
    locale: Locale('ja'),
    code: 'ja',
    displayName: '日本語',
  );

  static const kk = Languages._(
    locale: Locale('kk'),
    code: 'kk',
    displayName: 'қазақ тілі',
  );

  static const ko = Languages._(
    locale: Locale('ko'),
    code: 'ko',
    displayName: '한국어',
  );

  static const lv = Languages._(
    locale: Locale('lv'),
    code: 'lv',
    displayName: 'latviešu valoda',
  );

  static const lt = Languages._(
    locale: Locale('lt'),
    code: 'lt',
    displayName: 'lietuvių kalba',
  );

  static const ms = Languages._(
    locale: Locale('ms'),
    code: 'ms',
    displayName: 'Bahasa Melayu',
  );

  static const pl = Languages._(
    locale: Locale('pl'),
    code: 'pl',
    displayName: 'polski',
  );

  static const pt = Languages._(
    locale: Locale('pt'),
    code: 'pt',
    displayName: 'português',
  );

  static const ro = Languages._(
    locale: Locale('ro'),
    code: 'ro',
    displayName: 'română',
  );

  static const ru = Languages._(
    locale: Locale('ru'),
    code: 'ru',
    displayName: 'русский',
  );

  static const sr = Languages._(
    locale: Locale('sr'),
    code: 'sr',
    displayName: 'српски',
  );

  static const sk = Languages._(
    locale: Locale('sk'),
    code: 'sk',
    displayName: 'slovenčina',
  );

  static const sl = Languages._(
    locale: Locale('sl'),
    code: 'sl',
    displayName: 'slovenščina',
  );

  static const es = Languages._(
    locale: Locale('es'),
    code: 'es',
    displayName: 'español',
  );

  static const sw = Languages._(
    locale: Locale('sw'),
    code: 'sw',
    displayName: 'Kiswahili',
  );

  static const sv = Languages._(
    locale: Locale('sv'),
    code: 'sv',
    displayName: 'svenska',
  );

  static const tl = Languages._(
    locale: Locale('tl'),
    code: 'tl',
    displayName: 'Tagalog',
  );

  static const th = Languages._(
    locale: Locale('th'),
    code: 'th',
    displayName: 'ไทย',
  );

  static const tr = Languages._(
    locale: Locale('tr'),
    code: 'tr',
    displayName: 'Türkçe',
  );

  static const uk = Languages._(
    locale: Locale('uk'),
    code: 'uk',
    displayName: 'українська',
  );

  static const vi = Languages._(
    locale: Locale('vi'),
    code: 'vi',
    displayName: 'Tiếng Việt',
  );

  static const ku = Languages._(
    locale: Locale('ku'),
    code: 'ku',
    displayName: 'Kurdî',
  );
  static const ar = Languages._(
    locale: Locale('ar'),
    code: 'ar',
    displayName: 'العربية',
  );

  static final list = [
    // ku,
    ar,
    en,
    afr,
    am,

    bg,
    ca,
    zh,
    hr,
    cs,
    da,
    nl,

    et,
    fa,
    fi,
    fr,

    el,
    he,
    hi,
    hu,

    id,
    it,
    ja,
    // kk,
    ko,
    lv,
    lt,
    ms,
    pl,
    pt,
    ro,
    ru,

    sk,
    sl,
    es,
    sw,
    sv,
    tl,
    th,
    tr,
    // uk,
    vi,
  ];

  const Languages._({
    required this.code,
    required this.locale,
    required this.displayName,
  });

  final String code;
  final Locale locale;
  final String displayName;

  @override
  List<Object?> get props => [code];
}

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({Key? key}) : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  Languages? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLocale = Localizations.localeOf(context);
    final currentLanguage = Languages.list.firstWhere(
      (lang) => lang.locale.languageCode == currentLocale.languageCode,
      orElse: () => Languages.en,
    );

    setState(() {
      _selectedLanguage = currentLanguage;
    });
  }

  Future<void> _changeLanguage(Languages? newLanguage) async {
    if (newLanguage == null || newLanguage == _selectedLanguage) return;

    setState(() {
      _selectedLanguage = newLanguage;
    });

    final newLocale = newLanguage.locale;

    // Execute the language change operations
    context.setLocale(newLocale);
    context.read<LocaleCubit>().changeLocale(newLocale);

    var box = await Hive.openBox('settings');
    await box.put('locale', newLocale.languageCode);

    context.read<PlaylistBloc>().add(LoadPlaylists());
    context.read<ArtistListBloc>().add(FetchArtistList());
    context.read<AudioListBloc>().add(FetchAudioList());
    context.read<AlbumListBloc>().add(FetchAlbumList());

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Languages>(
      value: _selectedLanguage,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 16,
      ),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
      onChanged: _changeLanguage,
      items:
          Languages.list.map<DropdownMenuItem<Languages>>((Languages language) {
            return DropdownMenuItem<Languages>(
              value: language,
              child: Row(
                children: [
                  // If you have flag images, you can uncomment this:
                  // Image.asset(
                  //   language.image.assetName,
                  //   width: 24,
                  //   height: 16,
                  //   fit: BoxFit.cover,
                  // ),
                  // const SizedBox(width: 12),
                  Text(
                    language.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// Alternative: More compact version with custom decoration
class CompactLanguageDropdown extends StatelessWidget {
  const CompactLanguageDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final currentLanguage = Languages.list.firstWhere(
      (lang) => lang.locale.languageCode == currentLocale.languageCode,
      orElse: () => Languages.en,
    );

    return Row(
      children: [
        Icon(Icons.language, size: 24.sp, color: Colors.white),
        SizedBox(width: 20.w),
        DropdownButton<Languages>(
          padding: EdgeInsets.zero,
          underline: SizedBox.shrink(),
          value: currentLanguage,
          isDense: true,
          icon: SizedBox.shrink(),
          elevation: 8,

          style: TextStyles.titleLarge.copyWith(color: Colors.white),
          dropdownColor: globalBackgroundColor,
          onChanged: (Languages? newLanguage) async {
            if (newLanguage == null) return;

            final newLocale = newLanguage.locale;

            context.setLocale(newLocale);
            context.read<LocaleCubit>().changeLocale(newLocale);

            var box = await Hive.openBox('settings');
            await box.put('locale', newLocale.languageCode);

            context.read<PlaylistBloc>().add(LoadPlaylists());
            context.read<ArtistListBloc>().add(FetchArtistList());
            context.read<AudioListBloc>().add(FetchAudioList());
            context.read<AlbumListBloc>().add(FetchAlbumList());

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
          items:
              Languages.list.map((Languages language) {
                return DropdownMenuItem<Languages>(
                  value: language,
                  child: Text(
                    language.displayName,
                    style: TextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontFamily: FontFamily.changa,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
