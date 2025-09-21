import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';

class RootPage extends StatelessWidget {
  final Widget widget;

  const RootPage({super.key, required this.widget});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            globalBackgroundImagePath != null
                ? BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      File(globalBackgroundImagePath!),
                    ), // or AssetImage
                    fit: BoxFit.cover,
                  ),
                )
                : BoxDecoration(color: globalBackgroundColor ?? Colors.white),
        child: widget,
      ),
    );
  }
}
