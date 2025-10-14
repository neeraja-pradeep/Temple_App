import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 30)
class StoreOrderResponse {
  @HiveField(0)
  final int count;

  @HiveField(1)
  final String? next;

  @HiveField(2)
  final String? previous;

  @HiveField(3)
  final List<StoreOrder> results;

  StoreOrderResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory StoreOrderResponse.fromJson(Map<String, dynamic> json) {
    return StoreOrderResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => StoreOrder.fromJson(e))
          .toList(),
    );
  }
}

@HiveType(typeId: 31)
class StoreOrder {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String createdAt;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final String total;

  @HiveField(4)
  final ShippingAddress? shippingAddress;

  @HiveField(5)
  final ShippingAddress? billingAddress;

  @HiveField(6)
  final List<Order> lines;

  @HiveField(7)
  final String? razorpayOrderId;

  @HiveField(8)
  final String? razorpayPaymentId;

  @HiveField(9)
  final String? razorpaySignature;

  StoreOrder({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.total,
    this.shippingAddress,
    this.billingAddress,
    required this.lines,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    return StoreOrder(
      id: json['id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
      total: json['total'] ?? '0',
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      billingAddress: json['billing_address'] != null
          ? ShippingAddress.fromJson(json['billing_address'])
          : null,
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((e) => Order.fromJson(e))
          .toList(),
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
    );
  }
}

@HiveType(typeId: 32)
class ShippingAddress {
  @HiveField(0)
  final String street;

  @HiveField(1)
  final String city;

  @HiveField(2)
  final String state;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final String pincode;

  ShippingAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

@HiveType(typeId: 33)
class Order {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final ProductVariant productVariant;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final String price;

  Order({
    required this.id,
    required this.productVariant,
    required this.quantity,
    required this.price,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      productVariant: ProductVariant.fromJson(json['product_variant']),
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '0',
    );
  }
}

@HiveType(typeId: 34)
class ProductVariant {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String sku;

  @HiveField(3)
  final String price;

  @HiveField(4)
  final Product product;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.product,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: json['price'] ?? '0',
      product: Product.fromJson(json['product']),
    );
  }
}

@HiveType(typeId: 35)
class Product {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
