import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/audios_bottom_sheet.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class WaitingListWidget extends StatelessWidget {
  final double? size;
  final bool? showTitle;
  const WaitingListWidget({
    super.key,
    required this.audioBloc,
    this.size,
    this.showTitle = true,
  });

  final AudioPlayerBloc audioBloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5.sp,
      children: [
        ControlIconWidget(
          opacity: 1,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder:
                  (context) => AudiosBottomSheet(
                    initialIndex: audioBloc.currentIndex ?? 0,
                    audios: audioBloc.currentPlaylist,
                  ),
            );
          },
          size: size,
          svgGenImage: Assets.icons.musicLibrary,
        ),

        !showTitle!
            ? SizedBox.shrink()
            : Text(
              LocaleKeys.queue.tr(),
              style: TextStyles.titleMedium.copyWith(color: Colors.white),
            ),
      ],
    );
  }
}
