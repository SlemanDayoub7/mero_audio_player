import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/core/widgets/generic_app_bar.dart';
import 'package:mero_audio_player/core/widgets/generic_scaffold.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/ringtone/presentation/bloc/ringtone_bloc.dart';
import 'package:mero_audio_player/features/ringtone/presentation/bloc/ringtone_event.dart';
import 'package:mero_audio_player/features/ringtone/presentation/bloc/ringtone_state.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/ringtone/presentation/widgets/wave_slider.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/control_icon_widget.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';

class SetRingtonePage extends StatefulWidget {
  final AudioFile audioFile;
  const SetRingtonePage({super.key, required this.audioFile});

  @override
  State<SetRingtonePage> createState() => _SetRingtonePageState();
}

class _SetRingtonePageState extends State<SetRingtonePage> {
  double start = 0;
  double end = 0;
  bool loop = true;
  bool _isLoading = false;
  bool _isTrimming = false;

  static const platform = MethodChannel(
    'com.example.mero_audio_player/audio_trimmer',
  );

  Future<String?> _trimAudio(String inputPath, int startMs, int endMs) async {
    try {
      final String? outputPath = await platform.invokeMethod('trimAudio', {
        'inputPath': inputPath,
        'startMs': startMs,
        'endMs': endMs,
      });
      return outputPath;
    } on PlatformException {
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _setAsRingtone() async {
    bool success = false;
    if (_isLoading || _isTrimming) return;
    if (start >= end) {
      _showSnackBar(LocaleKeys.startMustBeBeforeEnd.tr());
      return;
    }

    setState(() {
      _isLoading = true;
      _isTrimming = true;
    });
    await Future.delayed(Duration(seconds: 1));
    try {
      final trimmedPath = await _trimAudio(
        widget.audioFile.data!,
        (start * 1000).round(),
        (end * 1000).round(),
      );

      if (trimmedPath == null) {
        _showSnackBar(LocaleKeys.errorOccurred.tr());
        return;
      }

      success = await RingtoneSet.setRingtoneFromFile(File(trimmedPath));
      if (success) {
        Navigator.pop(context, true); // العودة للصفحة السابقة فقط عند النجاح
      } else {
        _showSnackBar(LocaleKeys.errorOccurred.tr());
        // تبقى الصفحة مفتوحة
      }

      final tempFile = File(trimmedPath);
      if (await tempFile.exists()) await tempFile.delete();
    } catch (e) {
      _showSnackBar(LocaleKeys.errorOccurred.tr());
    } finally {
      setState(() {
        _isLoading = false;
        _isTrimming = false;
      });
    }
  }

  @override
  void initState() {
    start = 0;
    end = widget.audioFile.duration!.toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      appBar: GenericAppBar(title: LocaleKeys.setRingtone.tr()),
      body: Stack(
        children: [
          AppGradientBackground(),
          Container(color: Colors.white.withOpacity(0.1)),
          _isLoading || _isTrimming
              ? Center(
                child: Text(
                  LocaleKeys.setting_ringtone.tr(),
                  style: TextStyles.headlineLarge.copyWith(color: Colors.white),
                ),
              )
              : ListView(
                children: [
                  SizedBox(height: 50.h),
                  BlocBuilder<SetRingToneBloc, SetRingToneState>(
                    builder: (context, state) {
                      final bloc = context.read<SetRingToneBloc>();
                      final isPlaying = state is SetRingTonePlaying;
                      final currentPosition = state.position;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WaveSlider(
                            positionTextColor: Colors.white,
                            currentProgress:
                                currentPosition.inMilliseconds / 1000,
                            backgroundColor: Colors.grey.shade300,
                            heightWaveSlider: 200.h,
                            widthWaveSlider: 0.98.sw,
                            duration:
                                (widget.audioFile.duration! / 1000).toDouble(),
                            callbackStart: (duration) {
                              setState(() => start = duration);
                              context.read<SetRingToneBloc>().add(
                                RestartAudio(
                                  widget.audioFile.data!,
                                  start,
                                  end,
                                  loop: loop,
                                ),
                              );
                            },
                            callbackEnd: (duration) {
                              setState(() => end = duration);
                              context.read<SetRingToneBloc>().add(
                                RestartAudio(
                                  widget.audioFile.data!,
                                  start,
                                  end,
                                  loop: loop,
                                ),
                              );
                            },
                          ),
                          Text(
                            "${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          ControlIconWidget(
                            size: 70.sp,
                            svgGenImage:
                                isPlaying
                                    ? Assets.icons.pause
                                    : Assets.icons.play,
                            onPressed: () {
                              if (isPlaying) {
                                bloc.add(PauseAudio());
                              } else {
                                bloc.add(
                                  PlayAudio(
                                    widget.audioFile.data!,
                                    start,
                                    end,
                                    loop: loop,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    spacing: 10.w,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed:
                            _isLoading || _isTrimming ? null : _setAsRingtone,
                        icon: Icon(
                          Icons.music_note,
                          size: 20.sp,
                          color: globalBackgroundColor,
                        ),
                        label: Text(
                          LocaleKeys.save.tr(),
                          style: TextStyles.titleMedium.copyWith(
                            color: globalBackgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
