import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/chapter.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/create_audio_book/create_audio_book_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/create_audio_book/create_audio_book_event.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/create_audio_book/create_audio_book_state.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/widgets/slider_progress.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';

class CreateAudiobookPage extends StatelessWidget {
  final AudioFile audioFile;
  CreateAudiobookPage({super.key, required this.audioFile});

  String _formatMs(double ms) {
    final d = Duration(milliseconds: ms.toInt());
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? "$hh:$mm:$ss" : "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateAudiobookBloc(audioFile),
      child: BlocConsumer<CreateAudiobookBloc, CreateAudiobookState>(
        listener: (context, state) async {
          if (!state.isSaving && state.playlist.audios.isNotEmpty) {
            Playlist playlist = state.playlist;

            context.read<PlaylistBloc>().add(
              AddAudiobook(
                audios: playlist.audios,

                name: playlist.name,
                file: playlist.audios[0],
                chapters: playlist.chapters ?? [],
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<CreateAudiobookBloc>();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                maxLines: 2,
                "تقطيع لفصل او عدة فصول",
                style: TextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ),
            body: Stack(
              children: [
                AppGradientBackground(),
                state.isSaving
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: context.paddingHigh,
                      children: [
                        SizedBox(height: 90.h),
                        Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            onChanged: (val) => bloc.add(NameChanged(val)),
                            style: TextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),

                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(5.r),
                              labelText: "اسم القائمة",
                              labelStyle: TextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        context.emptySizedHeightHigh,
                        Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            style: TextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),

                            onChanged:
                                (val) => bloc.add(ChapterNameChanged(val)),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(5.r),
                              labelText: "اسم الفصل",
                              labelStyle: TextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        context.emptySizedHeightHigh,
                        Text(
                          "حدد البداية والنهاية: ${_formatMs(state.startMs)} — ${_formatMs(state.endMs)}",
                          style: TextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        StreamBuilder<Duration>(
                          stream: bloc.player.onPositionChanged,
                          builder: (context, snapshot) {
                            final position =
                                snapshot.data?.inMilliseconds.toDouble() ?? 0;
                            final total = audioFile.duration?.toDouble() ?? 1;

                            return Column(
                              children: [
                                Slider(
                                  min: 0,
                                  max: total,
                                  value: position.clamp(0, total),
                                  divisions: total ~/ 1000, // خطوة كل ثانية
                                  label:
                                      "${(position / 1000).toStringAsFixed(1)}s",
                                  onChanged: (value) {
                                    if (value > state.endMs ||
                                        value < state.startMs)
                                      return;

                                    bloc.player.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                    if (bloc.player.state ==
                                        PlayerState.paused) {
                                      bloc.player.resume();
                                    }
                                  },
                                ),
                                RangeSlider(
                                  min: 0,
                                  max: total,
                                  divisions: total ~/ 1000, // خطوة كل ثانية
                                  labels: RangeLabels(
                                    "${(state.startMs / 1000).toStringAsFixed(1)}s",
                                    "${(state.endMs / 1000).toStringAsFixed(1)}s",
                                  ),
                                  values: RangeValues(
                                    state.startMs,
                                    state.endMs,
                                  ),
                                  onChanged: (values) {
                                    bloc.add(
                                      RangeChanged(values.start, values.end),
                                    );
                                  },
                                  onChangeEnd: (values) {
                                    bloc.add(PlayRange());
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${(state.startMs / 1000).toStringAsFixed(1)}s",
                                    ),
                                    Text(
                                      "${(state.endMs / 1000).toStringAsFixed(1)}s",
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        StreamBuilder<Duration>(
                          stream: bloc.player.onPositionChanged,
                          builder: (context, snapshot) {
                            return SliderProgress(
                              padding: EdgeInsets.only(left: 15.w, right: 15.w),
                              trackHeight: 3.h,
                              enabledThumbRadius: 4.r,
                              //  padding: EdgeInsetsDirectional.only(start: 65.w),
                              position: snapshot.data ?? Duration(seconds: 0),
                              duration: Duration(
                                milliseconds: audioFile.duration!,
                              ),
                              onSeek: (duration) => bloc.player.seek(duration),
                            );
                          },
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            padding: EdgeInsets.only(left: 15.w, right: 15.w),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 8.r,
                            ),
                          ),
                          child: RangeSlider(
                            inactiveColor: Colors.transparent,
                            activeColor: globalBackgroundColor,

                            min: 0,
                            max: state.audioFile.duration?.toDouble() ?? 1,
                            values: RangeValues(state.startMs, state.endMs),
                            onChanged: (values) {
                              bloc.add(RangeChanged(values.start, values.end));
                            },
                            onChangeEnd: (value) {
                              bloc.add(PlayRange());
                            },
                          ),
                        ),

                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                int a =
                                    (((state.startMs / 1000).toInt()) -
                                        Duration(seconds: 1).inSeconds);

                                if (a < 0) a = 0;
                                a = a * 1000;
                                bloc.add(
                                  RangeChanged(a.toDouble(), state.endMs),
                                );
                              },
                              child: Text(
                                '-1s',
                                style: TextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                int a =
                                    (((state.endMs / 1000).toInt()) +
                                        Duration(seconds: 1).inSeconds);
                                a = a * 1000;
                                if (a >
                                    (state.audioFile.duration?.toInt() ?? 0)) {
                                  a = state.audioFile.duration ?? 0;
                                }
                                bloc.add(
                                  RangeChanged(state.startMs, a.toDouble()),
                                );
                              },
                              child: Text(
                                '+1s',
                                style: TextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  globalBackgroundColor,
                                ),
                              ),
                              onPressed: () => bloc.add(PlayRange()),
                              child: Text(
                                "تشغيل",
                                style: TextStyles.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  globalBackgroundColor,
                                ),
                              ),
                              onPressed: () => bloc.add(StopAudio()),
                              child: Text(
                                "إيقاف",
                                style: TextStyles.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              globalBackgroundColor,
                            ),
                          ),
                          onPressed: () => bloc.add(AddChapter()),
                          child: Text(
                            "حفظ الفصل",
                            style: TextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Divider(),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.chapters.length,
                          itemBuilder: (context, index) {
                            final ch = state.chapters[index];
                            return ListTile(
                              title: Text(
                                ch.title,
                                style: TextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                "${_formatMs(ch.startMs.toDouble())} — ${_formatMs(ch.endMs.toDouble())}",
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.play_arrow),
                                    tooltip: "تشغيل هذا الفصل",
                                    onPressed: () => bloc.add(PlayChapter(ch)),
                                  ),
                                  ControlIconWidget(
                                    icon: Icons.delete,
                                    color: globalBackgroundColor,
                                    opacity: 1,
                                    size: 20.sp,
                                    onPressed: () {
                                      final newList = List<Chapter>.from(
                                        state.chapters,
                                      )..removeAt(index);
                                      bloc.emit(
                                        state.copyWith(chapters: newList),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              globalBackgroundColor,
                            ),
                          ),
                          onPressed: () {
                            bloc.add(SaveAudiobook());
                          },
                          child: Text(
                            "حفظ القائمة ",
                            style: TextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
