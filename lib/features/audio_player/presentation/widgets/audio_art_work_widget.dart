import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/audio_file.dart';

class AudioArtworkWidget extends StatelessWidget {
  final AudioFile audio;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  const AudioArtworkWidget({
    super.key,
    required this.audio,
    this.size = 60,
    this.borderRadius = 35,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: QueryArtworkWidget(
          quality: 100,
          artworkQuality: FilterQuality.high,
          id: audio.id,
          keepOldArtwork: true,
          type: ArtworkType.AUDIO,

          nullArtworkWidget: Assets.icons.musicNote.svg(
            width: size,
            height: size,
            color: Colors.white,
          ),
          artworkHeight: size,
          artworkWidth: size,
          artworkFit: BoxFit.cover,
        ),
      ),
    );
  }
}
