// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeModelAdapter extends TypeAdapter<EpisodeModel> {
  @override
  final int typeId = 1;

  @override
  EpisodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpisodeModel(
      id: fields[0] as String,
      image: fields[1] as String?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      pageLink: fields[4] as String?,
      audio: fields[5] as String?,
      author: fields[6] as String?,
      duration: fields[7] as int?,
      pubDate: fields[8] as DateTime?,
    )..downloadPath = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, EpisodeModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.pageLink)
      ..writeByte(5)
      ..write(obj.audio)
      ..writeByte(6)
      ..write(obj.author)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.pubDate)
      ..writeByte(9)
      ..write(obj.downloadPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
