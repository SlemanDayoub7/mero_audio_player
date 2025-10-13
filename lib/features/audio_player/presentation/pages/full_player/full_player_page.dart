import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/app_background_image.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/artwork_player_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/audio_title_marquee.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/player_controls_bloc_builder.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/player_options_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/slider_progress.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/top_player_widget.dart';
import '../../bloc/audio_player/audio_player_bloc.dart';

class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key});

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage>
    with SingleTickerProviderStateMixin {
  String _swipeDirection = 'none';
  double _dragOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateBack() {
    _animation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final audioBloc = context.read<AudioPlayerBloc>();
    final player = audioBloc.playerHandler.player;

    return Scaffold(
      body: SizedBox(
        height: 1.sh,
        width: 1.sw,
        child: Stack(
          children: [
            AppBackgroundImage(isForPlayer: true),
            BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, state) {
                final current = state.current;
                if (current == null) return const SizedBox.shrink();

                return Column(
                  children: [
                    context.emptySizedHeightMedium,
                    TopPlayerWidget(current: current),

                    // 🎨 Interactive swipe artwork
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _dragOffset += details.delta.dx;
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          const threshold =
                              100; // distance required to trigger next/prev
                          if (_dragOffset.abs() > threshold) {
                            if (_dragOffset < 0) {
                              // Swipe Left → Next
                              _swipeDirection = 'left';
                              audioBloc.add(NextAudio());
                            } else {
                              // Swipe Right → Previous
                              _swipeDirection = 'right';
                              audioBloc.add(PreviousAudio());
                            }
                          }
                          _animateBack();
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            final offsetAnimation = Tween<Offset>(
                              begin:
                                  _swipeDirection == 'left'
                                      ? const Offset(1.0, 0.0)
                                      : _swipeDirection == 'right'
                                      ? const Offset(-1.0, 0.0)
                                      : Offset.zero,
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                            );

                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Transform.translate(
                            offset: Offset(_dragOffset, 0),
                            child: Transform.scale(
                              scale:
                                  1 - (_dragOffset.abs() / 600).clamp(0, 0.15),
                              child: Transform.rotate(
                                angle: (_dragOffset / 800).clamp(-0.15, 0.15),
                                child: ArtworkPlayerWidget(
                                  key: ValueKey(current.id ?? current.title),
                                  player: player,
                                  current: current,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 🎵 Rest of player layout
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.06.sw),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AudioTitleMarquee(audioTitle: current.title),
                            Text(
                              current.album ?? '',
                              style: TextStyles.displaySmall.copyWith(
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            PlayerOptionsWidget(audioBloc: audioBloc),
                            StreamBuilder<Duration>(
                              stream: player.positionStream,
                              builder: (context, snapshot) {
                                return Column(
                                  children: [
                                    SliderProgress(
                                      trackHeight: 4.h,
                                      enabledThumbRadius: 6.r,
                                      position: snapshot.data ?? Duration.zero,
                                      duration: Duration(
                                        milliseconds: current.duration ?? 0,
                                      ),
                                      onSeek:
                                          (duration) => player.seek(duration),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _fmt(snapshot.data ?? Duration.zero),
                                          style: TextStyles.headlineMedium
                                              .copyWith(color: Colors.white),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _fmt(
                                            Duration(
                                              milliseconds:
                                                  current.duration ?? 0,
                                            ),
                                          ),
                                          style: TextStyles.headlineMedium
                                              .copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: PlayerControlsBlocBuilder(
                        player: player,
                        audioBloc: audioBloc,
                        current: current,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${h == 0 ? '' : ('$h:')}$m:$s";
  }
}
