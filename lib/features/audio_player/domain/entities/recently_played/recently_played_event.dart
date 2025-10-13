import 'package:equatable/equatable.dart';

enum PlaySource { artist, playlist, audioList, album }

// Audio metadata model for recently played
class RecentlyPlayedAudio extends Equatable {
  final String id; // unique audio id
  final String artist;
  final PlaySource source;
  final String album;
  final String? playListName;

  RecentlyPlayedAudio({
    required this.id,
    required this.playListName,
    required this.artist,
    required this.source,
    required this.album,
  });

  // Serialize to map for Hive storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'playListName': playListName,
    'artist': artist,
    'source': source.toString(),
    'album': album,
  };

  // Deserialize from map
  factory RecentlyPlayedAudio.fromMap(Map<String, dynamic> map) {
    return RecentlyPlayedAudio(
      id: map['id'],
      playListName: map['playListName'],
      artist: map['artist'],
      album: map['album'],
      source: PlaySource.values.firstWhere(
        (e) => e.toString() == map['source'],
        orElse: () => PlaySource.audioList,
      ),
    );
  }

  @override
  List<Object?> get props => [id, artist, source, playListName, album];
}
