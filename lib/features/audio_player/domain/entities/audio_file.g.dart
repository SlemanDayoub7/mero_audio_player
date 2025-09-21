// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioFileAdapter extends TypeAdapter<AudioFile> {
  @override
  final int typeId = 0;

  @override
  AudioFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioFile(
      data: fields[12] as String?,
      genre: fields[13] as String?,
      id: fields[0] as int,
      title: fields[1] as String,
      artist: fields[2] as String?,
      album: fields[3] as String?,
      uri: fields[4] as String?,
      duration: fields[5] as int?,
      size: fields[6] as int?,
      displayName: fields[7] as String?,
      composer: fields[8] as String?,
      dateAdded: fields[9] as int?,
      track: fields[10] as int?,
      albumArtBytes: fields[11] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, AudioFile obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.uri)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.size)
      ..writeByte(7)
      ..write(obj.displayName)
      ..writeByte(8)
      ..write(obj.composer)
      ..writeByte(9)
      ..write(obj.dateAdded)
      ..writeByte(10)
      ..write(obj.track)
      ..writeByte(11)
      ..write(obj.albumArtBytes)
      ..writeByte(12)
      ..write(obj.data)
      ..writeByte(13)
      ..write(obj.genre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
