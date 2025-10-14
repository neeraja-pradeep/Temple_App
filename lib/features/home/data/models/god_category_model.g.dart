// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'god_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GodCategoryAdapter extends TypeAdapter<GodCategory> {
  @override
  final int typeId = 12;

  @override
  GodCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GodCategory(
      id: fields[0] as int,
      name: fields[1] as String,
      homemediaUrl: fields[2] as String?,
      isActive: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GodCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.homemediaUrl)
      ..writeByte(3)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GodCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
