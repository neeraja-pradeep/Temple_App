// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pooja_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PoojaAdapter extends TypeAdapter<Pooja> {
  @override
  final int typeId = 3;

  @override
  Pooja read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pooja(
      id: fields[0] as int,
      name: fields[1] as String,
      category: fields[2] as int,
      categoryName: fields[3] as String,
      price: fields[4] as String,
      status: fields[5] as bool,
      bannerDesc: fields[6] as String,
      cardDesc: fields[7] as String,
      captionsDesc: fields[8] as String,
      specialPooja: fields[9] as bool,
      specialPoojaDates: (fields[10] as List).cast<dynamic>(),
      mediaUrl: fields[11] as String,
      bannerUrl: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pooja obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.categoryName)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.bannerDesc)
      ..writeByte(7)
      ..write(obj.cardDesc)
      ..writeByte(8)
      ..write(obj.captionsDesc)
      ..writeByte(9)
      ..write(obj.specialPooja)
      ..writeByte(10)
      ..write(obj.specialPoojaDates)
      ..writeByte(11)
      ..write(obj.mediaUrl)
      ..writeByte(12)
      ..write(obj.bannerUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoojaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
