import 'package:flutter/material.dart';
import 'package:mero_audio_player/core/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final colors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.pink,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('تغيير الثيم')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          return GestureDetector(
            onTap: () {
              themeNotifier.setSeedColor(color);
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
            ),
          );
        },
      ),
    );
  }
}
