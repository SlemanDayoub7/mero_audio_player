import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/features/music_library/domain/entities/audio_file/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_widget.dart';
import 'package:mero_audio_player/core/di/injection.dart';

class AudiosBottomSheet extends StatefulWidget {
  final List<AudioFile> audios;
  final int initialIndex;

  const AudiosBottomSheet({
    super.key,
    required this.audios,
    required this.initialIndex,
  });

  @override
  State<AudiosBottomSheet> createState() => _AudiosBottomSheetState();
}

class _AudiosBottomSheetState extends State<AudiosBottomSheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex >= 0 &&
          widget.initialIndex < widget.audios.length) {
        final itemHeight = 65.h;
        final targetPosition = widget.initialIndex * itemHeight;
        final currentPosition = _scrollController.position.pixels;

        final distance = (targetPosition - currentPosition).abs();

        // حساب المدة بما يتناسب مع المسافة، مثلا 1 مللي ثانية لكل بكسل، مع حد أدنى وأقصى
        final durationMs = distance.clamp(100, 500).toInt();

        _scrollController.animateTo(
          targetPosition,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AppGradientBackground(),
          ListView.builder(
            controller: _scrollController,
            padding: context.paddingLow,
            itemCount: widget.audios.length,
            itemBuilder: (context, index) {
              final audio = widget.audios[index];
              return AudioWidget(
                showOptions: false,
                audio: audio,
                audios: widget.audios,
                playSourceL: playSource!,
              );
            },
          ),
        ],
      ),
    );
  }
}
