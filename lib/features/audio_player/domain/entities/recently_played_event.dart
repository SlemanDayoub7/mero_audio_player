import 'package:equatable/equatable.dart';

enum PlaySource { artist, playlist, audioList }

// Audio metadata model for recently played
class RecentlyPlayedAudio extends Equatable {
  final String id; // unique audio id

  final String artist;
  final PlaySource source;

  final String? playListName;

  RecentlyPlayedAudio({
    required this.id,
    required this.playListName,
    required this.artist,
    required this.source,
  });

  // Serialize to map for Hive storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'playListName': playListName,
    'artist': artist,
    'source': source.toString(),
  };

  // Deserialize from map
  factory RecentlyPlayedAudio.fromMap(Map<String, dynamic> map) {
    return RecentlyPlayedAudio(
      id: map['id'],
      playListName: map['playListName'],
      artist: map['artist'],
      source: PlaySource.values.firstWhere(
        (e) => e.toString() == map['source'],
        orElse: () => PlaySource.audioList,
      ),
    );
  }

  @override
  List<Object?> get props => [id, artist, source, playListName];
}
