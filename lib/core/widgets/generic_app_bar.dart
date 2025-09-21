import 'package:flutter/material.dart';

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle? titleTextStyle;
  final double elevation;

  const GenericAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.iconColor = Colors.white,
    this.titleTextStyle,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      iconTheme: IconThemeData(color: iconColor),
      shadowColor: Colors.transparent,
      backgroundColor: backgroundColor,
      title: Text(
        title,
        style:
            titleTextStyle ??
            TextStyle(
              color: iconColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: actions,
    );
  }
}
