import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/current_audio_detail_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/mini_music_visualizer_widget.dart';
import 'package:mero_audio_player/injection.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../../cubit/audio/audio_cubit.dart';
import '../../cubit/audio/audio_state.dart';
import '../../../domain/entities/audio_file.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({Key? key}) : super(key: key);

  @override
  State<AudiosPage> createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color ?? Colors.blueGrey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Column(
          children: [
            // مربع البحث
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن أغنية',
                prefixIcon: Icon(Icons.search, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: BlocBuilder<AudioCubit, AudioState>(
                builder: (context, state) {
                  if (state is AudioLoading || state is AudioInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AudioLoaded) {
                    // تصفية قائمة الأغاني حسب النص
                    final filteredAudios =
                        state.audios.where((audio) {
                          final titleLower = audio.title.toLowerCase();
                          final artistLower = audio.artist?.toLowerCase() ?? '';
                          return titleLower.contains(searchQuery) ||
                              artistLower.contains(searchQuery);
                        }).toList();

                    if (filteredAudios.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد أغاني مطابقة للبحث',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: filteredAudios.length,
                      separatorBuilder: (_, __) => SizedBox(height: 5.h),
                      itemBuilder: (context, index) {
                        final audio = filteredAudios[index];
                        return InkWell(
                          onTap: () {
                            final playerCubit =
                                context.read<AudioPlayerCubit>();
                            final playlistId = filteredAudios
                                .map((a) => a.id)
                                .join('-');

                            if (playerCubit.currentPlaylistId != playlistId) {
                              playerCubit.loadPlaylist(
                                filteredAudios,
                                startIndex: index,
                              );
                            } else {
                              if (!playerCubit.isCurrentPlaying(index)) {
                                playerCubit.playIndex(index);
                              }
                            }

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => CurrentAudioDetailPage(),
                            );
                          },
                          child: Row(
                            children: [
                              AudioArtworkWidget(
                                audio: audio,
                                size: 45,
                                borderRadius: 8,
                              ),
                              SizedBox(width: 7.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      audio.title,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      audio.artist ?? '',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              MiniMusicVisualizerWidget(id: audio.id),
                              Icon(Icons.more_vert, size: 20.r),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state is AudioError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
