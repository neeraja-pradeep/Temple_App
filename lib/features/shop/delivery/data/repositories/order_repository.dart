import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';

class OrderLineModel {
  final int id;
  final String productName;
  final String variantName;
  final String sku;
  final String price;
  final int quantity;

  OrderLineModel({
    required this.id,
    required this.productName,
    required this.variantName,
    required this.sku,
    required this.price,
    required this.quantity,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    final variant = json['product_variant'] as Map<String, dynamic>? ?? {};
    final product = variant['product'] as Map<String, dynamic>? ?? {};
    return OrderLineModel(
      id: json['id'] as int? ?? 0,
      productName: product['name']?.toString() ?? '',
      variantName: variant['name']?.toString() ?? '',
      sku: variant['sku']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}

class OrderDetailModel {
  final int id;
  final String createdAt;
  final String status;
  final String total;
  final Map<String, dynamic>? shippingAddress;
  final List<OrderLineModel> lines;

  OrderDetailModel({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.shippingAddress,
    required this.lines,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final List linesJson = json['lines'] as List? ?? [];
    return OrderDetailModel(
      id: json['id'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      total: json['total']?.toString() ?? '0',
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      lines: linesJson.map((e) => OrderLineModel.fromJson(e)).toList(),
    );
  }
}

class OrderRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<OrderDetailModel> fetchOrderById(int orderId) async {
    final uri = Uri.parse("$baseUrl/ecommerce/orders/$orderId");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return OrderDetailModel.fromJson(data);
    }
    throw Exception('Failed to fetch order: ${response.statusCode}');
  }
}
