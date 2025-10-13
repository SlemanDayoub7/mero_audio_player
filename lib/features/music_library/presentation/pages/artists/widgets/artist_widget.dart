import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class ArtistWidget extends StatelessWidget {
  const ArtistWidget({super.key, required this.artist});

  final dynamic artist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Row(
        children: [
          ControlIconWidget(svgGenImage: Assets.icons.musicArtist, size: 40.sp),
          context.emptySizedWidthLow,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.artist,
                  style: TextStyles.titleMedium.copyWith(color: Colors.white),
                  maxLines: 1,
                ),
                context.emptySizedHeightLow,
                Text(
                  '${artist.numberOfTracks} ${LocaleKeys.song.tr()}',
                  style: TextStyles.titleSmall.copyWith(color: Colors.white),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
