// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/recently_played/recently_played_event.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';

import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/selection_mode_row_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/sort_order_playback_widget.dart';

import 'package:mero_audio_player/generated/codegen_loader.g.dart';

import '../../bloc/audio_list/audio_list_bloc.dart';

class AudiosPage extends StatefulWidget {
  final TextEditingController controller = TextEditingController();
  AudiosPage({super.key});

  @override
  State<AudiosPage> createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  bool selectionMode = false;
  final Set<AudioFile> selected = {};

  void toggleSelection(AudioFile audio) {
    setState(() {
      if (selected.contains(audio)) {
        selected.remove(audio);
      } else {
        selected.add(audio);
      }
      if (selected.isEmpty) selectionMode = false;
    });
  }

  void exitSelectionMode() {
    setState(() {
      selected.clear();
      selectionMode = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectionMode) {
          exitSelectionMode();
          return false;
        }
        return true;
      },
      child: RefreshIndicator(
        backgroundColor: globalBackgroundColor,
        color: Colors.white,
        onRefresh: () async {
          context.read<AudioListBloc>().add(FetchAudioList());
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.w, left: 8.w),
              child: SearchField(
                controller: widget.controller,
                hintText: LocaleKeys.searchAudioFile.tr(),
                onChanged: (query) {
                  context.read<AudioListBloc>().add(SearchAudio(query));
                },
              ),
            ),

            SortOrderPlaybackWidget(),

            Expanded(
              child: BlocBuilder<AudioListBloc, AudioListState>(
                builder: (context, state) {
                  if (state is AudioListLoading) {
                    return AppCircularProgressIndicator();
                  } else if (state is AudioListLoaded) {
                    final audios = state.audios;
                    if (audios.isEmpty) {
                      return Center(
                        child: Text(
                          LocaleKeys.noResults.tr(),
                          style: TextStyles.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ListView.builder(
                          padding:
                              selectionMode
                                  ? EdgeInsets.only(
                                    left: 8.w,
                                    right: 8.w,
                                    top: 8.w,
                                    bottom: 90.h,
                                  )
                                  : context.paddingLow,

                          itemCount: audios.length,
                          itemBuilder: (context, index) {
                            final audio = audios[index];
                            return AudioWidget(
                              audio: audio,
                              audios: audios,
                              image:
                                  index <= 5
                                      ? 'assets/images/${index + 1}.jpg'
                                      : null,
                              selectionMode: selectionMode,
                              playSourceL: PlaySource.audioList,
                              isSelected: selected.contains(audio),
                              onTap:
                                  selectionMode
                                      ? () => toggleSelection(audio)
                                      : null, // تشغيل عادي لو مش في وضع التحديد
                              onLongPress: () {
                                setState(() {
                                  selectionMode = true;
                                  toggleSelection(audio);
                                });
                              },
                            );
                          },
                        ),

                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder:
                        //             (context) => AudioTrimPro(
                        //               filePath: audios[0].data ?? '',
                        //             ),
                        //       ),
                        //     );
                        //   },
                        //   child: Text('data'),
                        // ),
                        // if (showScrollToSelectedButton &&
                        //     audioPlayerState.currentIndex != null)
                        //   Positioned(
                        //     bottom: 16,
                        //     right: 16,
                        //     child: FloatingActionButton(
                        //       backgroundColor: Colors.black.withOpacity(0.7),
                        //       onPressed: _scrollToSelected,
                        //       child: Icon(
                        //         color: Colors.white,
                        //         scrollArrowUp
                        //             ? Icons.arrow_upward
                        //             : Icons.arrow_downward,
                        //       ),
                        //       mini: true,
                        //     ),
                        //   ),
                        if (selectionMode) ...[
                          SelectionModeRowWidget(
                            playSource: PlaySource.audioList,
                            bottomMargin: 0,
                            onSelectAll: () {
                              selected.length == audios.length
                                  ? selected.clear()
                                  : selected.addAll(audios);
                              setState(() {});
                            },
                            selected: selected,
                            audiosLength: audios.length,
                          ),
                        ],
                      ],
                    );
                  } else if (state is AudioListError) {
                    return AppErrorText(errorMessage: state.message);
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
