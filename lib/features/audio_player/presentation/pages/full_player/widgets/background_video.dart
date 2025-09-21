// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class BackgroundVideo extends StatefulWidget {
//   final String videoAssetPath;
//   const BackgroundVideo({required this.videoAssetPath, Key? key})
//     : super(key: key);

//   @override
//   _BackgroundVideoState createState() => _BackgroundVideoState();
// }

// class _BackgroundVideoState extends State<BackgroundVideo> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset(
//         widget.videoAssetPath,
//         videoPlayerOptions: VideoPlayerOptions(
//           mixWithOthers: true,
//         ), // للتشغيل دون مقاطعة الصوت
//       )
//       ..initialize().then((_) {
//         _controller.setLooping(true);
//         _controller.setVolume(0);
//         _controller.play();
//         setState(() {});
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _controller.value.isInitialized
//         ? SizedBox.expand(
//           child: FittedBox(
//             fit: BoxFit.cover,
//             child: SizedBox(
//               width: _controller.value.size.width,
//               height: _controller.value.size.height,
//               child: VideoPlayer(_controller),
//             ),
//           ),
//         )
//         : Container(color: Colors.black);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
