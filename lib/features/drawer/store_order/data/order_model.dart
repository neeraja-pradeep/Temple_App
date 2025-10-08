class StoreOrderResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<StoreOrder> results;

  StoreOrderResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory StoreOrderResponse.fromJson(Map<String, dynamic> json) {
    return StoreOrderResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => StoreOrder.fromJson(e))
          .toList(),
    );
  }
}

class StoreOrder {
  final int id;
  final String createdAt;
  final String status;
  final String total;
  final ShippingAddress? shippingAddress;
  final ShippingAddress? billingAddress;
  final List<OrderLine> lines;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
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
      id: json['id'],
      createdAt: json['created_at'],
      status: json['status'],
      total: json['total'],
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      billingAddress: json['billing_address'] != null
          ? ShippingAddress.fromJson(json['billing_address'])
          : null,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => OrderLine.fromJson(e))
          .toList(),
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
    );
  }
}

class ShippingAddress {
  final String street;
  final String city;
  final String state;
  final String country;
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
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
    );
  }
}

class OrderLine {
  final int id;
  final ProductVariant productVariant;
  final int quantity;
  final String price;

  OrderLine({
    required this.id,
    required this.productVariant,
    required this.quantity,
    required this.price,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      id: json['id'],
      productVariant: ProductVariant.fromJson(json['product_variant']),
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final String price;
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
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      price: json['price'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final int id;
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}
