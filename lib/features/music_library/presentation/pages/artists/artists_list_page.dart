import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/core/widgets/app_no_data_text.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/music_library/presentation/pages/artists/artist_detail_page.dart';
import 'package:mero_audio_player/features/music_library/presentation/pages/artists/widgets/artist_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/core/di/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AzArtist {
  final String tag;
  final ArtistModel original;

  AzArtist({required this.tag, required this.original});
}

class ArtistListPage extends StatefulWidget {
  const ArtistListPage({super.key});

  @override
  State<ArtistListPage> createState() => _ArtistListPageState();
}

class _ArtistListPageState extends State<ArtistListPage> {
  final TextEditingController controller = TextEditingController();
  late Map<String, List<AzArtist>> groupedArtists;
  late List<String> indexChars;
  final ScrollController _scrollController = ScrollController();

  List<AzArtist> _buildAzList(List<ArtistModel> artists) {
    List<AzArtist> list =
        artists.map((artist) {
          String firstChar = artist.artist[0];
          if (RegExp(r'^[\u0600-\u06FF\u0750-\u077F]').hasMatch(firstChar)) {
            return AzArtist(tag: firstChar, original: artist);
          } else {
            return AzArtist(tag: firstChar.toUpperCase(), original: artist);
          }
        }).toList();

    list.sort((a, b) => a.tag.compareTo(b.tag));
    return list;
  }

  void _groupData(List<AzArtist> azList) {
    groupedArtists = {};
    for (var artist in azList) {
      groupedArtists.putIfAbsent(artist.tag, () => []);
      groupedArtists[artist.tag]!.add(artist);
    }
    indexChars = groupedArtists.keys.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: globalBackgroundColor,
      color: Colors.white,
      onRefresh: () async {
        context.read<ArtistListBloc>().add(FetchArtistList());
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: SearchField(
              controller: controller,

              onChanged: (query) {
                context.read<ArtistListBloc>().add(SearchArtist(query: query));
              },
              hintText: LocaleKeys.searchArtist.tr(),
            ),
          ),
          context.emptySizedHeightLow,
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
                  _groupData(azList);

                  return Row(
                    children: [
                      // Container(
                      //   width: 32.w,
                      //   color: globalBackgroundColor?.withOpacity(0.3),
                      //   child: ListView.builder(
                      //     itemCount: indexChars.length,
                      //     itemBuilder: (context, index) {
                      //       final letter = indexChars[index];
                      //       final isArabic = RegExp(
                      //         r'^[\u0600-\u06FF]',
                      //       ).hasMatch(letter);
                      //       return GestureDetector(
                      //         onTap: () => _scrollToTag(letter),
                      //         child: Container(
                      //           height: 24.h,
                      //           alignment: Alignment.center,
                      //           child: Text(
                      //             letter,
                      //             style: TextStyles.titleSmall.copyWith(
                      //               color: isArabic ? Colors.amber : Colors.white,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),
                      Expanded(
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers:
                              indexChars.map((tag) {
                                final artists = groupedArtists[tag]!;
                                return SliverStickyHeader(
                                  header: Container(
                                    height: 50.h,
                                    color: globalBackgroundColor?.withOpacity(
                                      0.3,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      tag,
                                      style: TextStyles.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final artist = artists[index].original;
                                      return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          start: 10.w,
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BlocProvider<
                                                      ArtistListBloc
                                                    >(
                                                      create:
                                                          (
                                                            context,
                                                          ) => ArtistListBloc(
                                                            repository:
                                                                Injection
                                                                    .audioRepository,
                                                          )..add(
                                                            FetchSongsByArtist(
                                                              artistName:
                                                                  artist.artist,
                                                            ),
                                                          ),
                                                      child: ArtistDetailPage(
                                                        artist: artist,
                                                      ),
                                                    ),
                                              ),
                                            );
                                            context.read<ArtistListBloc>().add(
                                              FetchArtistList(),
                                            );
                                          },
                                          child: ArtistWidget(artist: artist),
                                        ),
                                      );
                                    }, childCount: artists.length),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  );
                } else if (state is ArtistListError) {
                  return AppErrorText(errorMessage: state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
