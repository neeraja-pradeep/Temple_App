import 'package:hive/hive.dart';
import 'package:temple/features/special/data/models/special_pooja_model.dart';

// SpecialPooja Adapter 

class SpecialPoojaAdapter extends TypeAdapter<SpecialPooja> {
  @override
  final int typeId = 0;

  @override
  SpecialPooja read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return SpecialPooja(
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
      specialPoojaDates: (fields[10] as List).cast<SpecialPoojaDate>(),
      mediaUrl: fields[11] as String,
      bannerUrl: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SpecialPooja obj) {
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
}

// SpecialPoojaDate Adapter 

class SpecialPoojaDateAdapter extends TypeAdapter<SpecialPoojaDate> {
  @override
  final int typeId = 1;

  @override
  SpecialPoojaDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return SpecialPoojaDate(
      id: fields[0] as int,
      pooja: fields[1] as int,
      poojaName: fields[2] as String,
      date: fields[3] as String,
      malayalamDate: fields[4] as String,
      time: fields[5] as String?,
      price: fields[6] as String,
      status: fields[7] as bool,
      banner: fields[8] as bool,
      createdAt: fields[9] as String,
      modifiedAt: fields[10] as String,
      linkedOrdersCount: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpecialPoojaDate obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pooja)
      ..writeByte(2)
      ..write(obj.poojaName)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.malayalamDate)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.banner)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.modifiedAt)
      ..writeByte(11)
      ..write(obj.linkedOrdersCount);
  }
}
