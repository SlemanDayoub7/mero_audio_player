import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class AppErrorText extends StatelessWidget {
  final String? errorMessage;
  const AppErrorText({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('${LocaleKeys.errorOccurred.tr()} $errorMessage'),
    );
  }
}
