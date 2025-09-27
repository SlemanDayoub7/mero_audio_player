import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mero_audio_player/features/audio_player/domain/entities/audio_file.dart';
import 'package:mero_audio_player/features/audio_player/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/full_player/full_player_page.dart';
import 'package:mero_audio_player/gen/assets.gen.dart';
import 'package:mero_audio_player/generated/codegen_loader.g.dart';

class AddToFavoriteWidget extends StatefulWidget {
  final AudioFile audioFile;

  AddToFavoriteWidget({super.key, required this.audioFile});

  @override
  State<AddToFavoriteWidget> createState() => _AddToFavoriteWidgetState();
}

bool isFavorite = false;

class _AddToFavoriteWidgetState extends State<AddToFavoriteWidget> {
  @override
  Widget build(BuildContext context) {
    final playlistBloc = context.read<PlaylistBloc>();
    isFavorite = playlistBloc.isFavorite(widget.audioFile.id);
    return ControlIconWidget(
      svgGenImage:
          isFavorite ? Assets.icons.favoriteFill : Assets.icons.favoriteOutline,

      onPressed: () {
        if (isFavorite) {
          context.read<PlaylistBloc>().add(
            RemoveAudioFromPlaylist('0', widget.audioFile),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleKeys.file_removed_from_favorites.tr()),
            ),
          );
        } else {
          // context.read<PlaylistBloc>().add(CreatePlaylist('0'));
          context.read<PlaylistBloc>().add(
            AddAudioToPlaylist('0', widget.audioFile),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.file_added_to_favorites.tr())),
          );
        }
        setState(() {});
      },
    );
  }
}
