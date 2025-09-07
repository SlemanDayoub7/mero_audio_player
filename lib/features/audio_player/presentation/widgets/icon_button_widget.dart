import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final double? size;
  const IconButtonWidget({super.key, required this.icon, this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () {}, icon: Icon(icon, size: size));
  }
}
