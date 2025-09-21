import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class RotatingWhilePlayingWidget extends StatefulWidget {
  final Widget child;
  final AudioPlayer player;
  final Duration duration;

  const RotatingWhilePlayingWidget({
    super.key,
    required this.child,
    required this.player,
    this.duration = const Duration(seconds: 5),
  });

  @override
  _RotatingWhilePlayingWidgetState createState() =>
      _RotatingWhilePlayingWidgetState();
}

class _RotatingWhilePlayingWidgetState extends State<RotatingWhilePlayingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Listen to the playing stream to start/stop rotation
    widget.player.playingStream.listen((isPlaying) {
      if (isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        // Reset rotation to stable state
        _controller.reset();
      }
    });

    // Start or reset animation based on current player state
    if (widget.player.playing) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _controller, child: widget.child);
  }
}
