import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/core/widgets/app_no_data_text.dart';
import 'package:mero_audio_player/core/widgets/generic_app_bar.dart';
import 'package:mero_audio_player/core/widgets/generic_scaffold.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/create_playlist_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/injection.dart';

class AddToPlaylistPage extends StatelessWidget {
  final List<AudioFile> audios;
  const AddToPlaylistPage({super.key, required this.audios});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return GenericScaffold(
      appBar: GenericAppBar(title: "اختر قائمة التشغيل"),
      body: Stack(
        children: [
          AppGradientBackground(),
          Padding(
            padding: EdgeInsets.only(top: 90.h),
            child: Column(
              children: [
                Row(
                  spacing: 5.w,
                  children: [
                    context.emptySizedWidthLow,
                    Expanded(
                      child: SearchField(
                        controller: controller,
                        hintText: LocaleKeys.searchPlaylist.tr(),
                        onChanged: (query) {
                          context.read<PlaylistBloc>().add(
                            SearchPlaylist(query),
                          );
                        },
                      ),
                    ),
                    CreatePlaylistIcon(),
                    context.emptySizedWidthLow,
                  ],
                ),
                Expanded(
                  child: BlocBuilder<PlaylistBloc, PlaylistState>(
                    builder: (context, state) {
                      if (state is PlaylistLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PlaylistLoaded) {
                        var playlists = state.playlists;
                        if (playlists.isEmpty) {
                          return AppNoDataText();
                        }
                        ;
                        return ListView.separated(
                          padding: context.paddingLow,
                          separatorBuilder:
                              (context, index) => context.emptySizedHeightLow,
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];

                            return InkWell(
                              onTap: () async {
                                await confirmAndExecute(
                                  context: context,
                                  confirmMessage: LocaleKeys.addToPlaylist.tr(),
                                  errorMessage: '',
                                  successMessage:
                                      LocaleKeys.audioAddedToList.tr() +
                                      playlist.name,
                                  action: () async {
                                    final playlistBloc =
                                        context.read<PlaylistBloc>();
                                    for (var audio in audios) {
                                      playlistBloc.add(
                                        AddAudioToPlaylist(
                                          playlist.name,
                                          audio,
                                        ),
                                      );
                                    }
                                  },
                                );
                                Navigator.pop(context);
                                // Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                // decoration: BoxDecoration(
                                //   color:
                                //       playlist.isAudiobook
                                //           ? Colors.blueGrey[900]
                                //           : Colors.grey[850],
                                //   borderRadius: BorderRadius.circular(10.r),
                                //),
                                child: Row(
                                  children: [
                                    Icon(
                                      playlist.isAudiobook
                                          ? Icons.book
                                          : Icons.queue_music,
                                      color: Colors.white,
                                      size: 30.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            playlist.name,
                                            maxLines: 1,
                                            style: TextStyles.titleLarge
                                                .copyWith(color: Colors.white),
                                          ),
                                          Text(
                                            "${playlist.audios.length} ${LocaleKeys.song}",
                                            style: TextStyles.titleMedium
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is PlaylistError) {
                        return AppErrorText(errorMessage: state.message);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePlaylistIcon extends StatelessWidget {
  const CreatePlaylistIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 45.h,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.playlist_add, size: 30.sp, color: Colors.white),
            Text(
              LocaleKeys.addPlaylist.tr(),
              style: TextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BlocProvider(
                  create:
                      (context) =>
                          AudioListBloc(repository: Injection.audioRepository)
                            ..add(FetchAudioList()),
                  child: CreatePlaylistPage(),
                ),
          ),
        );
      },
    );
  }
}
