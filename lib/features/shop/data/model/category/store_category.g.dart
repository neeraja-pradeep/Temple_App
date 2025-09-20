// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreCategoryAdapter extends TypeAdapter<StoreCategory> {
  @override
  final int typeId = 9;

  @override
  StoreCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreCategory(
      id: fields[0] as int,
      name: fields[1] as String,
      mediaUrl: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StoreCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mediaUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
