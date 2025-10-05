// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/bloc/equalizer/equalizer_bloc.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/bloc/equalizer/equalizer_event.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/bloc/equalizer/equalizer_state.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/widgets/vertical_slider.dart';

// class CustomEQBloc extends StatelessWidget {
//   final EqualizerState state;
//   const CustomEQBloc(this.state, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: DropdownButton<String>(
//             value: state.selectedPreset,
//             hint: const Text("Select Preset"),
//             isExpanded: true,
//             items:
//                 state.presets
//                     .map(
//                       (preset) =>
//                           DropdownMenuItem(value: preset, child: Text(preset)),
//                     )
//                     .toList(),
//             onChanged:
//                 state.enabled
//                     ? (value) {
//                       if (value != null) {
//                         context.read<EqualizerBloc>().add(ApplyPreset(value));
//                       }
//                     }
//                     : null,
//           ),
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             for (int i = 0; i < state.centerFreqs.length; i++)
//               Expanded(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 250,
//                       child: RotatedBox(
//                         quarterTurns: 1,
//                         child: SliderTheme(
//                           data: SliderTheme.of(context).copyWith(
//                             trackHeight: 1,
//                             trackShape: SliderCustomTrackShape(),
//                           ),
//                           child: Slider(
//                             min: state.bandLevelRange[0].toDouble(),
//                             max: state.bandLevelRange[1].toDouble(),
//                             value: state.bandLevels[i],
//                             onChanged:
//                                 state.enabled
//                                     ? (value) => context
//                                         .read<EqualizerBloc>()
//                                         .add(ChangeBandLevel(i, value))
//                                     : null,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Text('${state.centerFreqs[i] ~/ 1000} Hz'),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
