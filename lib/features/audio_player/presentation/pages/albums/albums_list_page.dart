import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/core/widgets/app_no_data_text.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/album_list/album_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/albums/album_detail_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/albums/widgets/album_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/injection.dart';

class AlbumsListPage extends StatefulWidget {
  const AlbumsListPage({super.key});

  @override
  State<AlbumsListPage> createState() => _AlbumsListPageState();
}

class _AlbumsListPageState extends State<AlbumsListPage> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: globalBackgroundColor,
      color: Colors.white,
      onRefresh: () async {
        context.read<AlbumListBloc>().add(FetchAlbumList());
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8.w, left: 8.w),
            child: SearchField(
              controller: controller,
              hintText: LocaleKeys.searchAlbum.tr(),
              onChanged: (query) {
                context.read<AlbumListBloc>().add(SearchAlbum(query: query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<AlbumListBloc, AlbumListState>(
              builder: (context, state) {
                if (state is AlbumListLoading) {
                  return AppCircularProgressIndicator();
                } else if (state is AlbumListLoaded) {
                  if (state.Albums.isEmpty) {
                    return AppNoDataText();
                  }

                  final albums = state.Albums;

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];

                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BlocProvider<AlbumListBloc>(
                                    create:
                                        (context) => AlbumListBloc(
                                          repository: Injection.audioRepository,
                                        )..add(
                                          FetchSongsByAlbum(
                                            AlbumName: album.album,
                                          ),
                                        ),
                                    child: AlbumDetailPage(album: album),
                                  ),
                            ),
                          );
                        },
                        child: AlbumWidget(album: album),
                      );
                    },
                  );
                } else if (state is AlbumListError) {
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
