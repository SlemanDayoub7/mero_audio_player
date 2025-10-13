import 'package:flutter/material.dart';
import 'package:mero_audio_player/features/settings/presentation/pages/change_background/change_background_page.dart';

class AppGradientBackground extends StatelessWidget {
  final bool? isForPlayer;
  const AppGradientBackground({super.key, this.isForPlayer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            isForPlayer!
                ? gradientFromColorTwo(globalBackgroundColor ?? Colors.black)
                : gradientFromColor(globalBackgroundColor ?? Colors.black),
      ),
    );
  }
}
