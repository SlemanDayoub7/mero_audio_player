import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../music_library/domain/entities/audio_file/audio_file.dart';

class AudioArtworkWidget extends StatelessWidget {
  final AudioFile audio;
  final double size;
  final double borderRadius;
  final bool? showNullWidget;
  final bool? showIconNullWidget;
  final Color? backgroundColor;
  const AudioArtworkWidget({
    super.key,
    required this.audio,
    this.size = 60,
    this.borderRadius = 35,
    this.backgroundColor,
    this.showNullWidget = true,
    this.showIconNullWidget = false,
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
          size: 1024,

          format: ArtworkFormat.JPEG,
          artworkQuality: FilterQuality.high,
          id: audio.id,
          keepOldArtwork: true,
          type: ArtworkType.AUDIO,

          nullArtworkWidget:
              showIconNullWidget!
                  ? Assets.icons.music.svg(
                    width: size,
                    height: size,
                    color: Colors.white,
                  )
                  : showNullWidget!
                  ? Assets.images.logo.image(width: size, height: size)
                  : SizedBox.shrink(),
          artworkHeight: size,
          artworkWidth: size,
          artworkFit: BoxFit.cover,
        ),
      ),
    );
  }
}
