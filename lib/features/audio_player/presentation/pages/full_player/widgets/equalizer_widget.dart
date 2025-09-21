// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';

// class EqualizerWidget extends StatefulWidget {
//   final AudioPlayerBloc bloc;

//   const EqualizerWidget({super.key, required this.bloc});

//   @override
//   State<EqualizerWidget> createState() => _EqualizerWidgetState();
// }

// class _EqualizerWidgetState extends State<EqualizerWidget> {
//   String? selectedPreset;

//   @override
//   Widget build(BuildContext context) {
//     final bloc = widget.bloc;

//     // إذا الـ EQ غير متاح، نعرض رسالة
//     if (!bloc.eqAvailable || bloc.eqMin == null || bloc.eqMax == null) {
//       return Column(
//         children: [
//           const Text("Equalizer not available on this device."),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () => bloc.add(OpenSystemEQ()),
//             child: const Text("Open Device Equalizer (if supported)"),
//           ),
//         ],
//       );
//     }

//     final min = bloc.eqMin!;
//     final max = bloc.eqMax!;

//     return Scaffold(
//       body: Column(
//         children: [
//           SwitchListTile(
//             title: const Text('Enable Custom EQ'),
//             value: bloc.customEQEnabled,
//             onChanged: (val) {
//               bloc.add(ToggleCustomEQ(val));
//               setState(() {}); // لتحديث Sliders
//             },
//           ),
//           ElevatedButton(
//             onPressed: () => bloc.add(OpenSystemEQ()),
//             child: const Text('Open Device Equalizer'),
//           ),
//           const SizedBox(height: 20),
//           FutureBuilder<List<int>>(
//             future: bloc.getBandCenterFreqs(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const CircularProgressIndicator();
//               }
//               final freqs = snapshot.data!;
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children:
//                     freqs.asMap().entries.map((entry) {
//                       final bandId = entry.key;
//                       final freq = entry.value;
//                       return FutureBuilder<int>(
//                         future: bloc.getBandLevel(bandId),
//                         builder: (context, levelSnap) {
//                           final level = levelSnap.data?.toDouble() ?? 0.0;
//                           return Expanded(
//                             child: Column(
//                               children: [
//                                 RotatedBox(
//                                   quarterTurns: 1,
//                                   child: Slider(
//                                     min: min,
//                                     max: max,
//                                     value: level.clamp(min, max),
//                                     onChanged:
//                                         bloc.customEQEnabled
//                                             ? (val) => bloc.setBandLevel(
//                                               bandId,
//                                               val.toInt(),
//                                             )
//                                             : null,
//                                   ),
//                                 ),
//                                 Text('${freq ~/ 1000} Hz'),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     }).toList(),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           FutureBuilder<List<String>>(
//             future: bloc.getPresets(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const SizedBox.shrink();
//               }
//               final presets = snapshot.data!;
//               return DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Select Preset',
//                   border: OutlineInputBorder(),
//                 ),
//                 value: selectedPreset,
//                 onChanged:
//                     bloc.customEQEnabled
//                         ? (val) {
//                           if (val != null) {
//                             selectedPreset = val;
//                             bloc.setPreset(val);
//                             setState(() {});
//                           }
//                         }
//                         : null,
//                 items:
//                     presets.map((preset) {
//                       return DropdownMenuItem(
//                         value: preset,
//                         child: Text(preset),
//                       );
//                     }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
