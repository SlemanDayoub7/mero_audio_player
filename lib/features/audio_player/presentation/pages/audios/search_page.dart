import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio/audio_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio/audio_state.dart';
import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/current_audio_detail_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/audio_art_work_widget.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/mini_music_visualizer_widget.dart';

import '../../../domain/entities/audio_file.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color ?? Colors.blueGrey;

    return Scaffold(
      appBar: AppBar(title: Text("البحث"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
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
            SizedBox(height: 12.h),
            Expanded(
              child: BlocBuilder<AudioCubit, AudioState>(
                builder: (context, state) {
                  if (state is AudioLoading || state is AudioInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AudioLoaded) {
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
                          'لا توجد نتائج مطابقة',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredAudios.length,
                      separatorBuilder: (_, __) => SizedBox(height: 6.h),
                      itemBuilder: (context, index) {
                        final audio = filteredAudios[index];
                        return InkWell(
                          onTap: () {
                            final playerCubit =
                                context.read<AudioPlayerCubit>();
                            playerCubit.loadPlaylist(
                              filteredAudios,
                              startIndex: index,
                            );

                            playerCubit.playIndex(index);

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const CurrentAudioDetailPage(),
                            );
                          },
                          child: Row(
                            children: [
                              AudioArtworkWidget(
                                audio: audio,
                                size: 50,
                                borderRadius: 10,
                              ),
                              SizedBox(width: 8.w),
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
                        'خطأ: ${state.message}',
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
