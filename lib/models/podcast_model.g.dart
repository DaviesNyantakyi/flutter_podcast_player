// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PodcastModelAdapter extends TypeAdapter<PodcastModel> {
  @override
  final int typeId = 0;

  @override
  PodcastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PodcastModel(
      id: fields[0] as String,
      image: fields[1] as String?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      author: fields[4] as String?,
      rss: fields[6] as String?,
      pageLink: fields[5] as String?,
      episodes: (fields[7] as List?)?.cast<EpisodeModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PodcastModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.author)
      ..writeByte(5)
      ..write(obj.pageLink)
      ..writeByte(6)
      ..write(obj.rss)
      ..writeByte(7)
      ..write(obj.episodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
