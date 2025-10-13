import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/add_to_favorite_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';

class TopPlayerWidget extends StatelessWidget {
  const TopPlayerWidget({super.key, required this.current});

  final AudioFile current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          ControlIconWidget(
            icon: Icons.arrow_back,
            size: 35.sp,
            opacity: 0,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              current.artistOrUnknown,
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          AddToFavoriteWidget(audioFile: current),
        ],
      ),
    );
  }
}
