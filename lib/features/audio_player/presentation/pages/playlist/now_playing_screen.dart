import 'package:flutter/material.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/current_audio_detail/current_audio_detail_page.dart';
import '../../../domain/entities/playlist.dart';

class NowPlayingScreen extends StatelessWidget {
  final Playlist playlist;
  const NowPlayingScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return CurrentAudioDetailPage(); // تستخدم نفس صفحة الأغنية الحالية
  }
}
