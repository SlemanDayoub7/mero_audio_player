import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/music_library/presentation/bloc/audio_list/audio_list_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:mero_audio_player/core/di/injection.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SortOrderPlaybackWidget extends StatefulWidget {
  final bool? showSortOrder;
  const SortOrderPlaybackWidget({Key? key, this.showSortOrder = true})
    : super(key: key);

  @override
  _SortOrderPlaybackWidgetState createState() =>
      _SortOrderPlaybackWidgetState();
}

class _SortOrderPlaybackWidgetState extends State<SortOrderPlaybackWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          !widget.showSortOrder!
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
      children: [
        context.emptySizedWidthLow,
        // Sort Dropdown
        !widget.showSortOrder!
            ? SizedBox.shrink()
            : SizedBox(
              width: (0.25).sw,
              child: DropdownButton<SongSortType>(
                dropdownColor: globalBackgroundColor,
                value: selectedSort,
                iconEnabledColor: Colors.white,
                padding: EdgeInsets.zero,
                isExpanded: true,
                underline: SizedBox.shrink(),
                hint: Text(
                  'ترتيب حسب',
                  style: TextStyles.titleSmall.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                items:
                    SongSortType.values.map((type) {
                      String label;
                      switch (type) {
                        case SongSortType.ARTIST:
                          label = LocaleKeys.artist.tr();
                          break;
                        case SongSortType.DATE_ADDED:
                          label = LocaleKeys.dateAdded.tr();
                          break;
                        case SongSortType.TITLE:
                          label = LocaleKeys.title.tr();
                          break;
                        case SongSortType.ALBUM:
                          label = LocaleKeys.album.tr();
                          break;
                        case SongSortType.DURATION:
                          label = LocaleKeys.duration.tr();
                          break;
                        case SongSortType.SIZE:
                          label = LocaleKeys.size.tr();
                          break;
                        case SongSortType.DISPLAY_NAME:
                          label = LocaleKeys.displayName.tr();
                          break;
                      }
                      return DropdownMenuItem<SongSortType>(
                        value: type,
                        child: Text(
                          label,
                          style: TextStyles.titleSmall.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (newSort) {
                  setState(() {
                    selectedSort = newSort!;
                  });
                  Hive.box('settings').put('sortType', selectedSort!.index);
                  context.read<AudioListBloc>().add(
                    SortAudioList(selectedSort!, orderType),
                  );
                },
              ),
            ),
        !widget.showSortOrder!
            ? SizedBox.shrink()
            : SizedBox(
              width: (0.25).sw,
              child: DropdownButton<OrderType>(
                dropdownColor: globalBackgroundColor,
                value: orderType,
                iconEnabledColor: Colors.white,
                isExpanded: true,
                underline: SizedBox.shrink(),
                items:
                    OrderType.values.map((type) {
                      String label;
                      switch (type) {
                        case OrderType.ASC_OR_SMALLER:
                          label = LocaleKeys.ascending.tr();
                          break;
                        case OrderType.DESC_OR_GREATER:
                          label = LocaleKeys.descending.tr();
                          break;
                      }
                      return DropdownMenuItem<OrderType>(
                        value: type,
                        child: Text(
                          label,
                          style: TextStyles.titleSmall.copyWith(
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (newOrder) {
                  setState(() {
                    orderType = newOrder!;
                  });
                  Hive.box('settings').put('orderType', orderType.index);
                  context.read<AudioListBloc>().add(
                    SortAudioList(selectedSort!, orderType),
                  );
                },
              ),
            ),
        PlaybackModeDropDown(),
        context.emptySizedWidthLow,
      ],
    );
  }
}

class PlaybackModeDropDown extends StatelessWidget {
  const PlaybackModeDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return SizedBox(
          width: (0.25).sw,
          child: DropdownButton<PlaybackMode>(
            value: state.playbackMode,
            underline: SizedBox.shrink(),
            dropdownColor: globalBackgroundColor,
            isExpanded: true,
            icon:
                playbackMode == PlaybackMode.shuffle
                    ? Assets.icons.shuffle.svg(color: Colors.white)
                    : playbackMode == PlaybackMode.repeatOne
                    ? Assets.icons.repeateOne.svg(color: Colors.white)
                    : Assets.icons.repeate.svg(color: Colors.white),
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
                      maxLines: 2,
                      style: TextStyles.titleSmall.copyWith(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (newPlaybackMode) {
              playbackMode = newPlaybackMode!;

              context.read<AudioPlayerBloc>().add(
                TogglePlaybackMode(playbackMode: newPlaybackMode),
              );
            },
          ),
        );
      },
    );
  }
}
