import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/app_background_image.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/current_audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/sort_order_playback_widget.dart';
import 'package:mero_audio_player/injection.dart';

import '../../bloc/playlist/playlist_bloc.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;
  const PlaylistDetailPage({required this.playlist, super.key});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late List<AudioFile> audios;

  @override
  void initState() {
    super.initState();
    audios = List.from(widget.playlist.audios);
  }

  @override
  Widget build(BuildContext context) {
    final playlistBloc = context.read<PlaylistBloc>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          title: Text(
            widget.playlist.name,
            style: TextStyles.displayLarge.copyWith(color: Colors.white),
          ),
          // backgroundColor: Colors.transparent,
          // title: Text(widget.playlist.name,),
        ),
        body: Stack(
          children: [
            AppGradientBackground(),

            Padding(
              padding: EdgeInsets.only(bottom: 100.h, top: 90.h),
              child: Column(
                children: [
                  SortOrderPlaybackWidget(showSortOrder: false),
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: audios.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = audios.removeAt(oldIndex);
                          audios.insert(newIndex, item);
                        });
                        // Update playlist in Hive
                        final updatedPlaylist = Playlist(
                          name: widget.playlist.name,
                          audios: audios,
                          id: '',
                        );
                        playlistBloc.add(DeletePlaylist(widget.playlist.name));
                        playlistBloc.add(CreatePlaylist(updatedPlaylist.name));
                        for (var audio in audios) {
                          playlistBloc.add(
                            AddAudioToPlaylist(updatedPlaylist.name, audio),
                          );
                        }
                      },
                      itemBuilder: (context, index) {
                        final audio = audios[index];
                        playSource = PlaySource.playlist;
                        currentPlayListName = widget.playlist.name;
                        return AudioWidget(
                          audio: audio,
                          playListName: widget.playlist.name,
                          key: ValueKey(audio.id),
                          audios: audios,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // CurrentAudioWidget at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: CurrentAudioWidget(),
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   label: const Text("Play All"),
        //   icon: const Icon(Icons.play_arrow),
        //   onPressed: () {
        //     if (audios.isNotEmpty) {
        //       audioBloc.add(PlayAudio(audio: audios.first, audios: audios));
        //     }
        //   },
        // ),
      ),
    );
  }
}
