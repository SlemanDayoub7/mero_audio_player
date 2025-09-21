import 'package:flutter/material.dart';
import 'package:mero_audio_player/main_screen.dart';

class Sp extends StatelessWidget {
  const Sp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            ),
        child: Text('data'),
      ),
    );
  }
}
