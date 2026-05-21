import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:mero_audio_player/features/lyrics/presentation/pages/synced_lyrics_page.dart';

/// Enhanced full player page with lyrics button
/// 
/// This is a reference implementation showing how to add lyrics support
/// to the existing FullPlayerPage.
class FullPlayerPageWithLyrics extends FullPlayerPage {
  const FullPlayerPageWithLyrics({super.key});
}

/// Mixin to add lyrics functionality to any player widget
mixin LyricsPlayerMixin {
  /// Open synced lyrics page for current song
  void openSyncedLyrics(BuildContext context) {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentSong = audioPlayerBloc.state.current;

    if (currentSong == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No song is currently playing'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Fetch lyrics
    context.read<LyricsBloc>().add(
      FetchLyricsEvent(
        title: currentSong.title,
        artist: currentSong.artistOrUnknown,
        duration: Duration(milliseconds: currentSong.duration ?? 0),
      ),
    );

    // Navigate to synced lyrics
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SyncedLyricsPage(
          songTitle: currentSong.title,
          songArtist: currentSong.artistOrUnknown,
          songDuration: Duration(milliseconds: currentSong.duration ?? 0),
        ),
      ),
    );
  }
}

/// Widget to add a lyrics button to any player
class LyricsPlayerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LyricsPlayerButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.lyrics,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
