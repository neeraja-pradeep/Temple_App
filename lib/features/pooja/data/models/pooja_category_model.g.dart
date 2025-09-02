// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pooja_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PoojaCategoryAdapter extends TypeAdapter<PoojaCategory> {
  @override
  final int typeId = 2;

  @override
  PoojaCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PoojaCategory(
      id: fields[0] as int,
      name: fields[1] as String,
      parent: fields[2] as int?,
      mediaUrl: fields[3] as String,
      children: (fields[4] as List).cast<PoojaCategory>(),
      isActive: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PoojaCategory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parent)
      ..writeByte(3)
      ..write(obj.mediaUrl)
      ..writeByte(4)
      ..write(obj.children)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoojaCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
