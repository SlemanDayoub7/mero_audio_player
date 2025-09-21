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

  List<AzArtist> _buildAzList(List<dynamic> artists) {
    List<AzArtist> list =
        artists.map((artist) {
          String tag = artist.artist[0].toUpperCase();
          return AzArtist(tag: tag, original: artist);
        }).toList();

    // Sort and set tags
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
                  // indexBarAlignment:
                  //     context.locale.languageCode == 'ar'
                  //         ? Alignment.centerRight
                  //         : Alignment.centerLeft,
                  data: azList,
                  itemCount: azList.length,
                  itemBuilder: (context, index) {
                    final item = azList[index];
                    final artist = item.original;

                    return InkWell(
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
                      },
                      child: ArtistWidget(artist: artist),
                    );
                  },
                  indexBarMargin: EdgeInsets.zero,
                  indexBarOptions: IndexBarOptions(
                    needRebuild: true,
                    selectTextStyle: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                    selectItemDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    indexHintAlignment: Alignment.center,
                    indexHintTextStyle: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                    indexHintDecoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  susItemBuilder: (context, index) {
                    final tag = azList[index].getSuspensionTag();
                    return Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      alignment:
                          context.locale.languageCode == 'ar'
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      decoration: BoxDecoration(
                        gradient: gradientFromColor(
                          globalBackgroundColor ?? Colors.black,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyles.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                        textAlign:
                            context.locale.languageCode == 'ar'
                                ? TextAlign.left
                                : TextAlign.right,
                      ),
                    );
                  },
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
