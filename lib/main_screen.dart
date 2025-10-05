import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_drawer.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/features/about_us_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/albums/albums_list_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/artists/artists_list_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/audios/audios_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/playlist_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/current_audio_widget.dart';
import 'package:mero_audio_player/features/privacy_policy_page.dart';
import 'package:mero_audio_player/gen/fonts.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AudiosPage(),
    PlaylistPage(),
    ArtistListPage(),
    AlbumsListPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image:
            globalBackgroundImagePath != null
                ? DecorationImage(
                  image:
                      (globalBackgroundImagePath ?? '').contains('assets')
                          ? AssetImage(globalBackgroundImagePath ?? '')
                          : FileImage(File(globalBackgroundImagePath!)),
                  fit: BoxFit.cover,
                )
                : null,
        gradient: gradientFromColor(globalBackgroundColor ?? Colors.black),
      ),
      child: Scaffold(
        drawer: AppDrawer(
          onChangeBackground:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeBackgroundPage()),
              ),
          onPrivacyPolicy:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
              ),
          onAboutUs:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              ),
        ),
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(85.h),
            child: Column(
              children: [
                SizedBox(
                  height: 25.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      context.emptySizedWidthMedium,
                      Text(
                        'Mero Audio Player',
                        style: TextStyles.displayMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Builder(
                        builder: (context) {
                          return InkWell(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Icon(
                              color: Colors.white,
                              Icons.settings,
                              size: 25.sp,
                            ),
                          );
                        },
                      ),
                      context.emptySizedWidthMedium,
                    ],
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  indicatorPadding: EdgeInsets.zero,
                  padding: EdgeInsets.only(
                    left: 15.w,
                    right: 15.w,
                    bottom: 5.h,
                  ),
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  dividerColor: Colors.transparent,
                  indicatorWeight: 1.sp,

                  unselectedLabelColor: Colors.white70,
                  tabAlignment: TabAlignment.start,
                  labelPadding: EdgeInsetsDirectional.only(end: 35.w),
                  labelStyle: TextStyles.titleLarge.copyWith(
                    fontFamily: FontFamily.changa,
                  ),
                  unselectedLabelStyle: TextStyles.titleMedium.copyWith(
                    fontFamily: FontFamily.changa,
                  ),

                  tabs: [
                    Tab(text: LocaleKeys.audio.tr()),
                    Tab(text: LocaleKeys.playlists.tr()),
                    Tab(text: LocaleKeys.artists.tr()),
                    Tab(text: LocaleKeys.albums.tr()),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            AppGradientBackground(),
            //   AppBackgroundImage(),
            Padding(
              padding: EdgeInsets.only(top: 122.h, bottom: 94.h),
              child: IndexedStack(index: _selectedIndex, children: _pages),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: CurrentAudioWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
