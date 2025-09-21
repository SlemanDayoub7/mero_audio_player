import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/core/extensions/theme_extensions.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';
import 'package:mero_audio_player/core/widgets/app_circular_progress_indicator.dart';
import 'package:mero_audio_player/core/widgets/app_error_text.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/add_to_playlist_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/playlist/widgets/playlist_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_field.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';
import '../../bloc/playlist/playlist_bloc.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final ScrollController scrollController = ScrollController();
    return Column(
      children: [
        Row(
          children: [
            context.emptySizedWidthLow,
            Expanded(
              flex: 2,
              child: SearchField(
                controller: controller,
                hintText: LocaleKeys.searchPlaylist.tr(),
                onChanged: (query) {
                  context.read<PlaylistBloc>().add(SearchPlaylist(query));
                },
              ),
            ),

            Expanded(child: CreatePlaylistIcon()),
            context.emptySizedWidthLow,
          ],
        ),

        Expanded(
          child: BlocBuilder<PlaylistBloc, PlaylistState>(
            builder: (context, state) {
              if (state is PlaylistLoading) {
                return AppCircularProgressIndicator();
              } else if (state is PlaylistLoaded) {
                var playlists = state.playlists;
                if (playlists.isEmpty) {
                  return Center(
                    child: Text(
                      LocaleKeys.noPlaylists.tr(),
                      style: TextStyles.displayMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: context.paddingMedium,
                  separatorBuilder:
                      (context, index) => context.emptySizedHeightLow,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];

                    return PlaylistWidget(playlist: playlist);
                  },
                );
              } else if (state is PlaylistError) {
                return AppErrorText(errorMessage: state.message);
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}
