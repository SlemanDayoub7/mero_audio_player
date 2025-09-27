import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/core/widgets/app_no_data_text.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/artists/artist_detail_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/artists/widgets/artist_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Extend your artist model with ISuspensionBean
class AzArtist implements ISuspensionBean {
  final String tag;
  final dynamic original;
  bool _isShowSuspension = false; // Internal flag to show suspension

  AzArtist({required this.tag, required this.original});

  @override
  String getSuspensionTag() => tag;

  @override
  bool get isShowSuspension => _isShowSuspension;

  @override
  set isShowSuspension(bool show) {
    _isShowSuspension = show;
  }
}

class ArtistListPage extends StatefulWidget {
  const ArtistListPage({super.key});

  @override
  State<ArtistListPage> createState() => _ArtistListPageState();
}

class _ArtistListPageState extends State<ArtistListPage> {
  final TextEditingController controller = TextEditingController();

  List<AzArtist> _buildAzList(List<ArtistModel> artists) {
    List<AzArtist> list =
        artists.map((artist) {
          String firstChar = artist.artist[0];

          if (RegExp(r'^[\u0600-\u06FF\u0750-\u077F]').hasMatch(firstChar)) {
            return AzArtist(
              tag: firstChar,
              original: artist,
            ); // حرف عربي بدون تغيير
          } else {
            // الحرف غير عربي - حوله إلى upper case
            return AzArtist(tag: firstChar.toUpperCase(), original: artist);
          }
        }).toList();

    // ترتيب القائمة وإعداد حالة عرض الشريط
    SuspensionUtil.sortListBySuspensionTag(list);
    SuspensionUtil.setShowSuspensionStatus(list);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.w, left: 8.w),
          child: SearchField(
            controller: controller,
            hintText: LocaleKeys.searchArtist.tr(),
            onChanged: (query) {
              context.read<ArtistListBloc>().add(SearchArtist(query: query));
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<ArtistListBloc, ArtistListState>(
            builder: (context, state) {
              if (state is ArtistListLoading) {
                return AppCircularProgressIndicator();
              } else if (state is ArtistListLoaded) {
                if (state.artists.isEmpty) {
                  return AppNoDataText();
                }
                final azList = _buildAzList(state.artists);

                return AzListView(
                  indexBarAlignment:
                      context.locale.languageCode == 'ar'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  data: azList,

                  itemCount: azList.length,
                  itemBuilder: (context, index) {
                    final item = azList[index];
                    final artist = item.original;

                    return Padding(
                      padding: EdgeInsetsDirectional.only(start: 10.w),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BlocProvider<ArtistListBloc>(
                                    create:
                                        (context) => ArtistListBloc(
                                          repository: Injection.audioRepository,
                                        )..add(
                                          FetchSongsByArtist(
                                            artistName: artist.artist,
                                          ),
                                        ),
                                    child: ArtistDetailPage(artist: artist),
                                  ),
                            ),
                          );
                          context.read<ArtistListBloc>().add(FetchArtistList());
                        },
                        child: ArtistWidget(artist: artist),
                      ),
                    );
                  },
                  indexBarMargin: EdgeInsets.zero,
                  indexBarOptions: IndexBarOptions(
                    indexHintWidth: 50.w,
                    textStyle: TextStyles.titleSmall.copyWith(
                      color: Colors.white,
                    ),

                    needRebuild: true,
                    selectTextStyle: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                    selectItemDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: globalBackgroundColor,
                      border: Border.all(width: 0.1.r, color: Colors.white),
                    ),

                    indexHintAlignment: Alignment.center,
                    indexHintTextStyle: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                    indexHintDecoration: BoxDecoration(
                      color: globalBackgroundColor,

                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              } else if (state is ArtistListError) {
                return AppErrorText(errorMessage: state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
