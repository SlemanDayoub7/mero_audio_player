import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';

import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/cs.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/add_to_playlist_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';

void showAudioOptionsBottomSheet(BuildContext context, AudioFile audio) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: 300.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
    ),
    builder: (context) => AudioOptionsSheet(audio: audio),
  );
}

class AudioOptionsSheet extends StatelessWidget {
  final AudioFile audio;

  const AudioOptionsSheet({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
        gradient: gradientFromColor(
          globalBackgroundColor ?? Colors.black,
        ), // assuming gradient getter
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: Column(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            text: LocaleKeys.addToPlaylist.tr(),
            icon: Assets.icons.musicAdd,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddToPlaylistPage(audios: [audio]),
                ),
              );
            },
          ),
          SizedBox(height: 10.h),
          _buildOption(
            context,
            text: LocaleKeys.cutChapter.tr(),
            icon: Assets.icons.cut,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateAudiobookPage(audioFile: audio),
                ),
              );
            },
          ),
          SizedBox(height: 10.h),
          _buildOption(
            context,
            text: LocaleKeys.setRingtone.tr(),
            icon: Assets.icons.ringtone,
            onTap: () async {
              await confirmAndExecute(
                context: context,
                confirmMessage: LocaleKeys.currentAudioWillBeRingtone.tr(),
                errorMessage: '',
                successMessage: LocaleKeys.fileSetAsRingtone.tr(),
                action: () async {
                  bool success = false;
                  try {
                    success = await RingtoneSet.setRingtoneFromFile(
                      File(audio.data ?? ''),
                    );
                  } on PlatformException {
                    success = false;
                  }
                },
              );

              Navigator.pop(context);
            },
          ),
          SizedBox(height: 10.h),
          _buildOption(
            context,
            text: LocaleKeys.setNotificationTone.tr(),
            icon: Assets.icons.notificationRing,
            onTap: () async {
              await confirmAndExecute(
                context: context,
                confirmMessage:
                    LocaleKeys.currentAudioWillBeNotificationTone.tr(),
                errorMessage: '',
                successMessage: LocaleKeys.fileSetAsNotificationTone.tr(),
                action: () async {
                  bool success = false;
                  try {
                    success = await RingtoneSet.setNotificationFromFile(
                      File(audio.data ?? ''),
                    );
                  } on PlatformException {
                    success = false;
                  }
                },
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String text,
    required SvgGenImage icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 5.w,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon.svg(width: 30.w, height: 30.w, color: globalBackgroundColor),
          Text(
            text,
            style: TextStyles.headlineMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
