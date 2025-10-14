// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberModelAdapter extends TypeAdapter<MemberModel> {
  @override
  final int typeId = 27;

  @override
  MemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberModel(
      id: fields[0] as int,
      name: fields[1] as String,
      user: fields[2] as int,
      dob: fields[3] as String?,
      time: fields[4] as String?,
      personal: fields[5] as bool,
      attributes: (fields[6] as List).cast<MemberAttribute>(),
    );
  }

  @override
  void write(BinaryWriter writer, MemberModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.dob)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.personal)
      ..writeByte(6)
      ..write(obj.attributes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemberAttributeAdapter extends TypeAdapter<MemberAttribute> {
  @override
  final int typeId = 28;

  @override
  MemberAttribute read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberAttribute(
      id: fields[0] as int,
      userListId: fields[1] as int,
      nakshatram: fields[2] as int,
      nakshatramName: fields[3] as String,
      status: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MemberAttribute obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userListId)
      ..writeByte(2)
      ..write(obj.nakshatram)
      ..writeByte(3)
      ..write(obj.nakshatramName)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberAttributeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
