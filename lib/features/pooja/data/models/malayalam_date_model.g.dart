// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'malayalam_date_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MalayalamDateModelAdapter extends TypeAdapter<MalayalamDateModel> {
  @override
  final int typeId = 4;

  @override
  MalayalamDateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MalayalamDateModel(
      id: fields[0] as int,
      gregorianDate: fields[1] as String,
      malayalamDate: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MalayalamDateModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gregorianDate)
      ..writeByte(2)
      ..write(obj.malayalamDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MalayalamDateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
