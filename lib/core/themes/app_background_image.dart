import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/features/audio_player/presentation/change_background_page.dart';

class AppBackgroundImage extends StatelessWidget {
  final bool? isForPlayer;

  const AppBackgroundImage({super.key, this.isForPlayer = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        (globalBackgroundImagePath ?? '').contains('assets')
            ? Image.asset(
              globalBackgroundImagePath ?? '',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox.shrink();
              },
            )
            : Image.file(
              File(globalBackgroundImagePath ?? ''),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox.shrink();
              },
            ),

        AppGradientBackground(isForPlayer: isForPlayer),
        Container(color: Colors.black.withOpacity(0.1)),
      ],
    );
  }
}
