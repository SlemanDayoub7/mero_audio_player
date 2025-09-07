import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/audio_file.dart';

class AudioArtworkWidget extends StatelessWidget {
  final AudioFile audio;
  final double size;
  final double borderRadius;

  const AudioArtworkWidget({
    super.key,
    required this.audio,
    this.size = 60,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: QueryArtworkWidget(
          quality: 100,
          artworkQuality: FilterQuality.high,
          id: audio.id,
          keepOldArtwork: true,
          type: ArtworkType.AUDIO,
          nullArtworkWidget: Container(
            width: size,
            height: size,
            color: Colors.grey.shade300,
            child: Icon(
              Icons.music_note,
              size: size * 0.6,
              color: Colors.grey.shade600,
            ),
          ),
          artworkHeight: size,
          artworkWidth: size,
          artworkFit: BoxFit.cover,
        ),
      ),
    );
  }
}
