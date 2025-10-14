// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreOrderResponseAdapter extends TypeAdapter<StoreOrderResponse> {
  @override
  final int typeId = 30;

  @override
  StoreOrderResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreOrderResponse(
      count: fields[0] as int,
      next: fields[1] as String?,
      previous: fields[2] as String?,
      results: (fields[3] as List).cast<StoreOrder>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreOrderResponse obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.count)
      ..writeByte(1)
      ..write(obj.next)
      ..writeByte(2)
      ..write(obj.previous)
      ..writeByte(3)
      ..write(obj.results);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreOrderResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreOrderAdapter extends TypeAdapter<StoreOrder> {
  @override
  final int typeId = 31;

  @override
  StoreOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreOrder(
      id: fields[0] as int,
      createdAt: fields[1] as String,
      status: fields[2] as String,
      total: fields[3] as String,
      shippingAddress: fields[4] as ShippingAddress?,
      billingAddress: fields[5] as ShippingAddress?,
      lines: (fields[6] as List).cast<Order>(),
      razorpayOrderId: fields[7] as String?,
      razorpayPaymentId: fields[8] as String?,
      razorpaySignature: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StoreOrder obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.total)
      ..writeByte(4)
      ..write(obj.shippingAddress)
      ..writeByte(5)
      ..write(obj.billingAddress)
      ..writeByte(6)
      ..write(obj.lines)
      ..writeByte(7)
      ..write(obj.razorpayOrderId)
      ..writeByte(8)
      ..write(obj.razorpayPaymentId)
      ..writeByte(9)
      ..write(obj.razorpaySignature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShippingAddressAdapter extends TypeAdapter<ShippingAddress> {
  @override
  final int typeId = 32;

  @override
  ShippingAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShippingAddress(
      street: fields[0] as String,
      city: fields[1] as String,
      state: fields[2] as String,
      country: fields[3] as String,
      pincode: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShippingAddress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.street)
      ..writeByte(1)
      ..write(obj.city)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.pincode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 33;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as int,
      productVariant: fields[1] as ProductVariant,
      quantity: fields[2] as int,
      price: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productVariant)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductVariantAdapter extends TypeAdapter<ProductVariant> {
  @override
  final int typeId = 34;

  @override
  ProductVariant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductVariant(
      id: fields[0] as int,
      name: fields[1] as String,
      sku: fields[2] as String,
      price: fields[3] as String,
      product: fields[4] as Product,
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariant obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sku)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.product);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 35;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
