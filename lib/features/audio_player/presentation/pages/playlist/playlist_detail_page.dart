import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/core/widgets/generic_app_bar.dart';
import 'package:mero_audio_player/core/widgets/generic_scaffold.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/current_audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/selection_mode_row_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/sort_order_playback_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
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
  bool selectionMode = false;
  final Set<AudioFile> selected = {};

  void toggleSelection(AudioFile audio) {
    setState(() {
      if (selected.contains(audio)) {
        selected.remove(audio);
      } else {
        selected.add(audio);
      }
      if (selected.isEmpty) selectionMode = false;
    });
  }

  void exitSelectionMode() {
    setState(() {
      selected.clear();
      selectionMode = false;
    });
  }

  @override
  void initState() {
    super.initState();
    audios = List.from(widget.playlist.audios);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectionMode) {
          exitSelectionMode();
          return false;
        }
        return true;
      },
      child: GenericScaffold(
        appBar: GenericAppBar(
          title:
              widget.playlist.name == '0'
                  ? LocaleKeys.favorite.tr()
                  : widget.playlist.name,
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
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: audios.length,
                      // onReorder: (oldIndex, newIndex) {
                      //   setState(() {
                      //     if (newIndex > oldIndex) newIndex -= 1;
                      //     final item = audios.removeAt(oldIndex);
                      //     audios.insert(newIndex, item);
                      //   });
                      //   // Update playlist in Hive
                      //   final updatedPlaylist = Playlist(
                      //     name: widget.playlist.name,
                      //     audios: audios,
                      //     id: '',
                      //   );
                      //   playlistBloc.add(DeletePlaylist(widget.playlist.name));
                      //   playlistBloc.add(CreatePlaylist(updatedPlaylist.name));
                      //   for (var audio in audios) {
                      //     playlistBloc.add(
                      //       AddAudioToPlaylist(updatedPlaylist.name, audio),
                      //     );
                      //   }
                      // },
                      itemBuilder: (context, index) {
                        final audio = audios[index];
                        playSource = PlaySource.playlist;
                        currentPlayListName = widget.playlist.name;
                        return Row(
                          key: ValueKey(audio.id),
                          children: [
                            Expanded(
                              child: AudioWidget(
                                audio: audio,
                                playSourceL: PlaySource.playlist,
                                playListName: widget.playlist.name,
                                selectionMode: selectionMode,
                                isSelected: selected.contains(audio),
                                onTap:
                                    selectionMode
                                        ? () => toggleSelection(audio)
                                        : null, // تشغيل عادي لو مش في وضع التحديد
                                onLongPress: () {
                                  setState(() {
                                    selectionMode = true;
                                    toggleSelection(audio);
                                  });
                                },
                                audios: audios,
                              ),
                            ),
                            if (!selectionMode)
                              ControlIconWidget(
                                size: 25.sp,
                                borderColor: Colors.grey,
                                onPressed: () async {
                                  await confirmAndExecute(
                                    context: context,
                                    confirmMessage:
                                        LocaleKeys
                                            .file_will_be_removed_from_playlist
                                            .tr(),
                                    action: () async {
                                      context.read<PlaylistBloc>().add(
                                        RemoveAudioFromPlaylist(
                                          widget.playlist.name,
                                          audio,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    successMessage:
                                        LocaleKeys.file_removed_from_playlist
                                            .tr(),
                                    errorMessage: LocaleKeys.delete_error.tr(),
                                  );
                                },
                                svgGenImage: Assets.icons.removeAll,
                              ),
                            context.emptySizedWidthLow,
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (selectionMode) ...[
              SelectionModeRowWidget(
                onSelectAll: () {
                  selected.length == audios.length
                      ? selected.clear()
                      : selected.addAll(audios);
                  setState(() {});
                },
                playlistName: widget.playlist.name,
                selected: selected,
                audiosLength: audios.length,
              ),
            ],
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
