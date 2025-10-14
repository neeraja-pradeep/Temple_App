// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingAdapter extends TypeAdapter<Booking> {
  @override
  final int typeId = 20;

  @override
  Booking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Booking(
      id: fields[0] as int,
      user: fields[1] as int,
      userDetails: fields[2] as UserDetails?,
      status: fields[3] as String?,
      statusDisplay: fields[4] as String?,
      total: fields[5] as String?,
      razorpayOrderId: fields[6] as String?,
      razorpayPaymentId: fields[7] as String?,
      refundAmount: fields[8] as String?,
      refundStatus: fields[9] as String?,
      refundStatusDisplay: fields[10] as String?,
      razorpayRefundId: fields[11] as String?,
      refundReason: fields[12] as String?,
      createdAt: fields[13] as String?,
      modifiedAt: fields[14] as String?,
      orderLines: (fields[15] as List).cast<OrderLine>(),
    );
  }

  @override
  void write(BinaryWriter writer, Booking obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.userDetails)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.statusDisplay)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.razorpayOrderId)
      ..writeByte(7)
      ..write(obj.razorpayPaymentId)
      ..writeByte(8)
      ..write(obj.refundAmount)
      ..writeByte(9)
      ..write(obj.refundStatus)
      ..writeByte(10)
      ..write(obj.refundStatusDisplay)
      ..writeByte(11)
      ..write(obj.razorpayRefundId)
      ..writeByte(12)
      ..write(obj.refundReason)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.modifiedAt)
      ..writeByte(15)
      ..write(obj.orderLines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserDetailsAdapter extends TypeAdapter<UserDetails> {
  @override
  final int typeId = 21;

  @override
  UserDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserDetails(
      id: fields[0] as int,
      email: fields[1] as String?,
      phoneNumber: fields[2] as String?,
      firstName: fields[3] as String?,
      lastName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserDetails obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderLineAdapter extends TypeAdapter<OrderLine> {
  @override
  final int typeId = 22;

  @override
  OrderLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderLine(
      id: fields[0] as int,
      pooja: fields[1] as int,
      poojaDetails: fields[2] as PoojaDetails?,
      specialPoojaDate: fields[3] as int?,
      specialPoojaDateDetails: fields[4] as SpecialPoojaDateDetails?,
      selectedDate: fields[5] as String?,
      userList: fields[6] as int,
      userListDetails: fields[7] as UserListDetails?,
      userAttribute: fields[8] as int,
      userAttributeDetails: fields[9] as UserAttributeDetails?,
      price: fields[10] as String?,
      effectivePrice: fields[11] as String?,
      status: fields[12] as String?,
      statusDisplay: fields[13] as String?,
      poojaStatus: fields[14] as String?,
      poojaStatusDisplay: fields[15] as String?,
      isCancelled: fields[16] as bool?,
      selectedDates: (fields[17] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderLine obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pooja)
      ..writeByte(2)
      ..write(obj.poojaDetails)
      ..writeByte(3)
      ..write(obj.specialPoojaDate)
      ..writeByte(4)
      ..write(obj.specialPoojaDateDetails)
      ..writeByte(5)
      ..write(obj.selectedDate)
      ..writeByte(6)
      ..write(obj.userList)
      ..writeByte(7)
      ..write(obj.userListDetails)
      ..writeByte(8)
      ..write(obj.userAttribute)
      ..writeByte(9)
      ..write(obj.userAttributeDetails)
      ..writeByte(10)
      ..write(obj.price)
      ..writeByte(11)
      ..write(obj.effectivePrice)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.statusDisplay)
      ..writeByte(14)
      ..write(obj.poojaStatus)
      ..writeByte(15)
      ..write(obj.poojaStatusDisplay)
      ..writeByte(16)
      ..write(obj.isCancelled)
      ..writeByte(17)
      ..write(obj.selectedDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PoojaDetailsAdapter extends TypeAdapter<PoojaDetails> {
  @override
  final int typeId = 23;

  @override
  PoojaDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PoojaDetails(
      id: fields[0] as int,
      name: fields[1] as String?,
      category: fields[2] as int?,
      categoryName: fields[3] as String?,
      price: fields[4] as String?,
      status: fields[5] as bool?,
      specialPooja: fields[6] as bool?,
      specialPoojaDates: (fields[7] as List).cast<SpecialPoojaDateDetails>(),
      mediaUrl: fields[8] as String?,
      bannerUrl: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PoojaDetails obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.specialPooja)
      ..writeByte(7)
      ..write(obj.specialPoojaDates)
      ..writeByte(8)
      ..write(obj.mediaUrl)
      ..writeByte(9)
      ..write(obj.bannerUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoojaDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpecialPoojaDateDetailsAdapter
    extends TypeAdapter<SpecialPoojaDateDetails> {
  @override
  final int typeId = 24;

  @override
  SpecialPoojaDateDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpecialPoojaDateDetails(
      id: fields[0] as int,
      pooja: fields[1] as int?,
      poojaName: fields[2] as String?,
      date: fields[3] as String?,
      malayalamDate: fields[4] as String?,
      time: fields[5] as String?,
      price: fields[6] as String?,
      status: fields[7] as bool?,
      banner: fields[8] as bool?,
      createdAt: fields[9] as String?,
      modifiedAt: fields[10] as String?,
      linkedOrdersCount: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SpecialPoojaDateDetails obj) {
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialPoojaDateDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserListDetailsAdapter extends TypeAdapter<UserListDetails> {
  @override
  final int typeId = 25;

  @override
  UserListDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserListDetails(
      id: fields[0] as int,
      name: fields[1] as String?,
      user: fields[2] as int?,
      attributes: (fields[3] as List).cast<UserAttributeDetails>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserListDetails obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.attributes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserListDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAttributeDetailsAdapter extends TypeAdapter<UserAttributeDetails> {
  @override
  final int typeId = 26;

  @override
  UserAttributeDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAttributeDetails(
      id: fields[0] as int,
      nakshatram: fields[1] as int?,
      nakshatramName: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAttributeDetails obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nakshatram)
      ..writeByte(2)
      ..write(obj.nakshatramName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAttributeDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
