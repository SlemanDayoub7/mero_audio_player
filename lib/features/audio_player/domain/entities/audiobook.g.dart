// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audiobook.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudiobookAdapter extends TypeAdapter<Audiobook> {
  @override
  final int typeId = 2;

  @override
  Audiobook read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Audiobook(
      id: fields[0] as String,
      file: fields[1] as AudioFile,
      chapters: (fields[2] as List).cast<Chapter>(),
    );
  }

  @override
  void write(BinaryWriter writer, Audiobook obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.file)
      ..writeByte(2)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudiobookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final int typeId = 3;

  @override
  Chapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chapter(
      title: fields[0] as String,
      startMs: fields[1] as int,
      endMs: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.startMs)
      ..writeByte(2)
      ..write(obj.endMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
