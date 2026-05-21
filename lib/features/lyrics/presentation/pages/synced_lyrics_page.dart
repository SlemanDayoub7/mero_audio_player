import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_state.dart';
import 'package:mero_audio_player/features/lyrics/presentation/widgets/lyrics_view.dart';

/// Extended lyrics page with synced lyrics support
class SyncedLyricsPage extends StatefulWidget {
  final String songTitle;
  final String songArtist;
  final Duration songDuration;

  const SyncedLyricsPage({
    Key? key,
    required this.songTitle,
    required this.songArtist,
    required this.songDuration,
  }) : super(key: key);

  @override
  State<SyncedLyricsPage> createState() => _SyncedLyricsPageState();
}

class _SyncedLyricsPageState extends State<SyncedLyricsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get audio player bloc to listen to position changes
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final player = audioPlayerBloc.playerHandler.player;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.songTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.songArtist,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Lyrics display
          BlocBuilder<LyricsBloc, LyricsState>(
            builder: (context, state) {
              if (state is LyricsLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (state is LyricsLoaded) {
                return LyricsView(
                  lyrics: state.lyrics,
                  currentLyricIndex: state.currentLyricIndex,
                  scrollController: _scrollController,
                );
              } else if (state is LyricsNotFound) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else if (state is LyricsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading lyrics',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Text(
                  'No lyrics available',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16.sp,
                  ),
                ),
              );
            },
          ),
          // Position listener to sync lyrics with playback
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Update lyrics with current position
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<LyricsBloc>().add(
                    UpdatePositionEvent(snapshot.data!),
                  );
                });
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
