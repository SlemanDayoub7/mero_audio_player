import 'package:flutter/material.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
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
    this.borderRadius = 35,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: QueryArtworkWidget(
          quality: 100,
          artworkQuality: FilterQuality.high,
          id: audio.id,
          keepOldArtwork: true,
          type: ArtworkType.AUDIO,

          nullArtworkWidget: Assets.icons.music.svg(
            width: size,
            height: size,
            color: globalBackgroundColor,
          ),
          artworkHeight: size,
          artworkWidth: size,
          artworkFit: BoxFit.cover,
        ),
      ),
    );
  }
}
