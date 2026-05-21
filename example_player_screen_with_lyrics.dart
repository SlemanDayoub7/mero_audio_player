import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:mero_audio_player/features/lyrics/presentation/pages/lyrics_page.dart';
import 'package:mero_audio_player/features/lyrics/presentation/widgets/lyrics_fab_button.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';

/// Example implementation of lyrics integration in player screen
class ExamplePlayerScreenWithLyrics extends StatefulWidget {
  final AudioFile currentSong;
  final Duration totalDuration;
  final Duration currentPosition;

  const ExamplePlayerScreenWithLyrics({
    Key? key,
    required this.currentSong,
    required this.totalDuration,
    required this.currentPosition,
  }) : super(key: key);

  @override
  State<ExamplePlayerScreenWithLyrics> createState() =>
      _ExamplePlayerScreenWithLyricsState();
}

class _ExamplePlayerScreenWithLyricsState
    extends State<ExamplePlayerScreenWithLyrics> {
  /// Show lyrics page when FAB is pressed
  void _showLyrics() {
    final lyricsBloc = context.read<LyricsBloc>();

    // Fetch lyrics
    lyricsBloc.add(
      FetchLyricsEvent(
        title: widget.currentSong.title ?? 'Unknown Song',
        artist: widget.currentSong.artist ?? 'Unknown Artist',
        duration: widget.totalDuration,
      ),
    );

    // Navigate to full-screen lyrics page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LyricsPage(
          songTitle: widget.currentSong.title ?? 'Unknown Song',
          songArtist: widget.currentSong.artist ?? 'Unknown Artist',
          songDuration: widget.totalDuration,
        ),
      ),
    );
  }

  /// Update lyrics position based on playback position
  void _updateLyricsPosition(Duration position) {
    context.read<LyricsBloc>().add(
          UpdatePositionEvent(position),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to position changes and sync lyrics
    _updateLyricsPosition(widget.currentPosition);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
              // Album art placeholder
              Expanded(
                child: Center(
                  child: Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Colors.grey[600],
                      size: 80.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              // Song info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Text(
                      widget.currentSong.title ?? 'Unknown Song',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.currentSong.artist ?? 'Unknown Artist',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              // Progress bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4.h,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6.r,
                        ),
                      ),
                      child: Slider(
                        value: widget.currentPosition.inSeconds.toDouble(),
                        max: widget.totalDuration.inSeconds.toDouble(),
                        onChanged: (_) {},
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey[600],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(widget.currentPosition),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          _formatDuration(widget.totalDuration),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 32.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      // Lyrics FAB button
      floatingActionButton: LyricsFABButton(
        onPressed: _showLyrics,
        isLoading: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  /// Format duration to MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
