import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'audio_file.g.dart';

@HiveType(typeId: 0)
class AudioFile extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? artist;

  @HiveField(3)
  final String? album;

  @HiveField(4)
  final String? uri;

  @HiveField(5)
  final int? duration;

  @HiveField(6)
  final int? size;

  @HiveField(7)
  final String? displayName;

  @HiveField(8)
  final String? composer;

  @HiveField(9)
  final int? year;

  @HiveField(10)
  final int? track;
  @HiveField(11)
  Uint8List? albumArtBytes; // لتخزين الصورة الأصلية كـ bytes

  AudioFile({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.uri,
    this.duration,
    this.size,
    this.displayName,
    this.composer,
    this.year,
    this.track,
    this.albumArtBytes,
  });

  /// تحويل من SongModel
  factory AudioFile.fromSongModel(SongModel song, {Uint8List? albumArt}) =>
      AudioFile(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        uri: song.uri,
        duration: song.duration,
        size: song.size,
        displayName: song.displayName,
        composer: song.composer,
        track: song.track,
        albumArtBytes: albumArt,
      );

  /// ⏱️ صيغة الوقت mm:ss
  String get formattedDuration {
    if (duration == null) return "00:00";
    final totalSeconds = duration! ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// 🎨 هل عنده صورة غلاف؟
  bool get hasArtwork => id > 0;

  /// 👤 اسم الفنان أو Unknown
  String get artistOrUnknown =>
      artist?.isNotEmpty == true ? artist! : "Unknown Artist";

  /// 💿 اسم الألبوم أو Unknown
  String get albumOrUnknown =>
      album?.isNotEmpty == true ? album! : "Unknown Album";
}
