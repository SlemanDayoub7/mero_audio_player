import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/core/widgets/app_no_data_text.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/artist_list/artist_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/current_audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/selection_mode_row_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/sort_order_playback_widget.dart';
import 'package:mero_audio_player/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistDetailPage extends StatefulWidget {
  final ArtistModel artist;

  const ArtistDetailPage({super.key, required this.artist});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  bool selectionMode = false;
  final Set<AudioFile> selected = {};
  List<AudioFile> audios = [];
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectionMode) {
          exitSelectionMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            AppGradientBackground(),
            Column(
              children: [
                context.emptySizedHeightHigh,
                Padding(
                  padding: context.paddingLow,
                  child: Text(
                    maxLines: 2,
                    widget.artist.artist,
                    style: TextStyles.titleLarge.copyWith(color: Colors.white),
                  ),
                ),
                SortOrderPlaybackWidget(showSortOrder: false),
                Expanded(
                  child: BlocBuilder<ArtistListBloc, ArtistListState>(
                    builder: (context, state) {
                      if (state is SongsByArtistLoading) {
                        return AppCircularProgressIndicator();
                      } else if (state is SongsByArtistLoaded) {
                        final songs = state.songs;
                        if (songs.isEmpty) {
                          return AppNoDataText();
                        }
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: selectionMode ? 184.h : 94.h,
                          ),
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            audios = songs;
                            playSource = PlaySource.artist;
                            return AudioWidget(
                              audio: song,
                              audios: songs,
                              playSource: PlaySource.artist,
                              artist: song.artist,
                              selectionMode: selectionMode,
                              isSelected: selected.contains(song),
                              onDelete: () {
                                context.read<ArtistListBloc>().add(
                                  FetchSongsByArtist(
                                    artistName: song.artist ?? '',
                                  ),
                                );
                              },
                              onTap:
                                  selectionMode
                                      ? () => toggleSelection(song)
                                      : null, // تشغيل عادي لو مش في وضع التحديد
                              onLongPress: () {
                                setState(() {
                                  selectionMode = true;
                                  toggleSelection(song);
                                });
                              },
                            );
                          },
                        );
                      } else if (state is SongsByArtistError) {
                        return AppErrorText(errorMessage: state.message);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
            if (selectionMode) ...[
              SelectionModeRowWidget(
                onSelectAll: () {
                  selected.length == audios.length
                      ? selected.clear()
                      : selected.addAll(audios);
                  setState(() {});
                },

                selected: selected,
                audiosLength: audios.length,
              ),
            ],
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
