import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/add_to_playlist_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:share_plus/share_plus.dart';

class SelectionModeRowWidget extends StatelessWidget {
  final Function() onSelectAll;
  final Set<AudioFile> selected;
  final int audiosLength;
  final double? bottomMargin;
  const SelectionModeRowWidget({
    super.key,
    required this.onSelectAll,
    required this.selected,
    required this.audiosLength,
    this.bottomMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin ?? 94.h),
        decoration: BoxDecoration(color: globalBackgroundColor),
        height: 80.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            context.emptySizedWidthLow,
            InkWell(
              onTap: onSelectAll,
              child: Center(
                child: Text(
                  selected.length == audiosLength
                      ? "إلغاء تحديد الكل"
                      : LocaleKeys.selectAll.tr(),
                  style: TextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Text(
                '${selected.length > 99999999 ? "+99999999" : selected.length} ${LocaleKeys.selected.tr()}',
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ),
            ControlIconWidget(
              svgGenImage: Assets.icons.share,
              onPressed: () async {
                final files = selected.map((a) => XFile(a.data ?? '')).toList();

                await Share.shareXFiles(files, text: 'مشاركه مقاطع صوتية');
              },
            ),
            ControlIconWidget(
              icon: Icons.playlist_add,
              opacity: 0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddToPlaylistPage(audios: selected.toList()),
                  ),
                );
              },
            ),

            context.emptySizedWidthLow,
          ],
        ),
      ),
    );
  }
}
