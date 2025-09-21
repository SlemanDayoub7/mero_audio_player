// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
// import 'package:mero_audio_player/core/themes/color_util.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/widgets/audio_controls.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/widgets/audio_title_marquee.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/widgets/slider_progress.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';
// import '../../cubit/audio_player/audio_player_cubit.dart';

// class CurrentAudioDetailPage extends StatefulWidget {
//   const CurrentAudioDetailPage({super.key});

//   @override
//   State<CurrentAudioDetailPage> createState() => _CurrentAudioDetailPageState();
// }

// class _CurrentAudioDetailPageState extends State<CurrentAudioDetailPage> {
//   AudioFile? _currentAudio;
//   Widget? _artworkWidget;
//   Widget? _marqueeWidget;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final cubit = context.read<AudioPlayerCubit>();

//     return Scaffold(
//       body: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
//         builder: (context, state) {
//           AudioFile? audio;
//           if (state is AudioPlayerPlaying) {
//             audio = state.audio;
//           } else if (state is AudioPlayerPaused) {
//             audio = state.audio;
//           }

//           // Calculate gradient based on current audio inside builder
//           final bgGradient =
//               (audio != null)
//                   ? LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: ColorUtil.getGradientColorsFromId(
//                       audio.id.toString(),
//                     ),
//                   )
//                   : LinearGradient(
//                     colors: [
//                       theme.colorScheme.background,
//                       theme.colorScheme.background.withOpacity(0.8),
//                     ],
//                   );

//           // Update _currentAudio and widgets if audio changes
//           if (audio != null && audio != _currentAudio) {
//             _currentAudio = audio;
//             _artworkWidget = AudioArtworkWidget(
//               audio: audio,
//               size: 300.r,
//               borderRadius: 20.r,
//             );
//             _marqueeWidget = AudioInfo(
//               audioTitle: audio.title ?? '',
//               theme: theme,
//             );
//           }

//           // render UI based on state as before

//           if (state is AudioPlayerInitial) {
//             return Center(child: Text("No song selected"));
//           }
//           if (state is AudioPlayerLoading) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (state is AudioPlayerCompleted) {
//             return Center(child: Text("Playback finished"));
//           }
//           if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
//             final pos =
//                 state is AudioPlayerPlaying
//                     ? state.position
//                     : (state as AudioPlayerPaused).position;
//             final dur =
//                 state is AudioPlayerPlaying
//                     ? state.duration
//                     : (state as AudioPlayerPaused).duration;
//             final isPlaying = state is AudioPlayerPlaying;

//             return Container(
//               decoration: BoxDecoration(gradient: bgGradient),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 20.h),
//                     _artworkWidget ?? Container(height: 300.h, width: 300.w),
//                     SizedBox(height: 40.h),
//                     _marqueeWidget ?? SizedBox(height: 30.h),
//                     SizedBox(height: 6.h),
//                     Text(
//                       audio!.artist ?? '',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onBackground.withOpacity(0.7),
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                     SizedBox(height: 30.h),
//                     SliderProgress(
//                       position: pos,
//                       duration: dur,
//                       onSeek: (duration) => cubit.seek(duration),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 4.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _fmt(pos),
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               fontSize: 12.sp,
//                             ),
//                           ),
//                           Text(
//                             _fmt(dur),
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               fontSize: 12.sp,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Spacer(),
//                     AudioControls(
//                       isPlaying: isPlaying,
//                       onPlayPause:
//                           () => isPlaying ? cubit.pause() : cubit.play(),
//                       onNext: cubit.next,
//                       onPrevious: cubit.previous,
//                     ),
//                     SizedBox(height: 40.h),
//                   ],
//                 ),
//               ),
//             );
//           }
//           return SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   String _fmt(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }
// }
