import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class AppNoDataText extends StatelessWidget {
  const AppNoDataText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LocaleKeys.noResults.tr(),
        style: TextStyles.displayMedium.copyWith(color: Colors.white),
      ),
    );
  }
}
