import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_dialog.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/core/widgets/app_gradient_background.dart';
import 'package:mero_audio_player/core/widgets/generic_app_bar.dart';
import 'package:mero_audio_player/core/widgets/generic_scaffold.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/sort_order_playback_widget.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import '../../../domain/entities/audio_file.dart';

import '../../bloc/audio_list/audio_list_bloc.dart';

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key});

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final Set<AudioFile> selectedAudios = {};
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      appBar: GenericAppBar(
        title: LocaleKeys.selectAudios.tr(),
        actions: [
          ControlIconWidget(
            icon: Icons.save,
            opacity: 0,
            onPressed: () async {
              if (selectedAudios.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(LocaleKeys.selectAtLeastOneAudioFile.tr()),
                  ),
                );
                return;
              }

              await showCreatePlaylistDialog(context, selectedAudios);
            },
          ),
          context.emptySizedWidthLow,
        ],
      ),
      body: Stack(
        children: [
          AppGradientBackground(),
          Column(
            children: [
              SizedBox(height: 90.h),
              SearchField(
                controller: controller,
                hintText: LocaleKeys.searchAudioFile.tr(),
                onChanged: (query) {
                  context.read<AudioListBloc>().add(SearchAudio(query));
                },
              ),
              SortOrderPlaybackWidget(),
              Expanded(
                child: BlocBuilder<AudioListBloc, AudioListState>(
                  builder: (context, state) {
                    if (state is AudioListLoading) {
                      return AppCircularProgressIndicator();
                    } else if (state is AudioListLoaded) {
                      final audios = state.audios;
                      return ListView.builder(
                        padding: EdgeInsets.only(),
                        shrinkWrap: true,
                        itemCount: audios.length,
                        itemBuilder: (context, index) {
                          final audio = audios[index];
                          final isSelected = selectedAudios.contains(audio);
                          return ListTile(
                            title: Text(
                              audio.title,
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              audio.artistOrUnknown,
                              style: TextStyles.titleMedium.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            ),
                            trailing:
                                isSelected
                                    ? Icon(Icons.check_box, color: Colors.white)
                                    : Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.white,
                                    ),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedAudios.remove(audio);
                                } else {
                                  selectedAudios.add(audio);
                                }
                              });
                            },
                          );
                        },
                      );
                    } else if (state is AudioListError) {
                      return AppErrorText(errorMessage: state.message);
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
