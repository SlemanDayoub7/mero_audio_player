import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/equalizer/presentation/pages/equalizer_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/audios_bottom_sheet.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/speed_drop_down.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/core/di/injection.dart';

class PlayerOptionsWidget extends StatelessWidget {
  const PlayerOptionsWidget({super.key, required this.audioBloc});

  final AudioPlayerBloc audioBloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 0.22.sw,
          child: SpeedDropdown(
            currentSpeed: audioBloc.state.speed,
            onChanged: (value) => audioBloc.add(SetPlaybackSpeed(value)),
          ),
        ),
        SizedBox(
          width: 0.22.sw,
          child: Stack(
            children: [
              Center(
                child: ControlIconWidget(
                  svgGenImage: Assets.icons.equalizer,
                  size: 35.sp,
                  onPressed:
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EqualizerPage(),
                          ),
                        ),
                      },
                ),
              ),
              // Align(
              //   alignment: Alignment.topRight,
              //   child: Text(data),
              // ),
            ],
          ),
        ),
        // Simple Equalizer Button - Opens Device Equalizer
        SizedBox(
          width: 0.22.sw,
          child: Center(
            child: DropdownButton<PlaybackMode>(
              underline: const SizedBox.shrink(),
              dropdownColor: globalBackgroundColor,
              value: playbackMode,
              menuWidth: 0.30.sw,
              selectedItemBuilder: (context) {
                return PlaybackMode.values.map((type) {
                  switch (type) {
                    case PlaybackMode.shuffle:
                      return Assets.icons.shuffle.svg(
                        color: Colors.white,
                        width: 25.sp,
                        height: 25.sp,
                      );
                    case PlaybackMode.repeatOne:
                      return Assets.icons.repeateOne.svg(
                        color: Colors.white,
                        width: 25.sp,
                        height: 25.sp,
                      );
                    case PlaybackMode.repeatAll:
                      return Assets.icons.repeate.svg(
                        color: Colors.white,
                        width: 25.sp,
                        height: 25.sp,
                      );
                  }
                }).toList();
              },
              icon: SizedBox.shrink(),
              items:
                  PlaybackMode.values.map((type) {
                    String label;
                    switch (type) {
                      case PlaybackMode.repeatAll:
                        label = LocaleKeys.repeatAll.tr();
                        break;
                      case PlaybackMode.repeatOne:
                        label = LocaleKeys.repeatCurrent.tr();
                        break;
                      case PlaybackMode.shuffle:
                        label = LocaleKeys.shuffle.tr();
                        break;
                    }
                    return DropdownMenuItem<PlaybackMode>(
                      value: type,
                      child: Text(
                        label,
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (newPlaybackMode) {
                playbackMode = newPlaybackMode!;
                audioBloc.add(
                  TogglePlaybackMode(playbackMode: newPlaybackMode),
                );
              },
            ),
          ),
        ),
        SizedBox(
          width: 0.22.sw,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              child: Assets.icons.musicLibrary.svg(
                color: Colors.white,

                width: 25.sp,
                height: 25.sp,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => AudiosBottomSheet(
                        initialIndex: audioBloc.currentIndex ?? 0,
                        audios: audioBloc.currentPlaylist,
                      ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
