import 'package:flutter/material.dart';

class GenericScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final Color backgroundColor;

  const GenericScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.extendBodyBehindAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
    );
  }
}
