import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/core/network/auth_headers.dart';

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
  Future<OrderDetailModel> fetchOrderById(int orderId) async {
    // Get authorization header with bearer token
    final authHeader = await AuthHeaders.requireToken();
    final headers = AuthHeaders.jsonFromHeader(authHeader);

    final uri = Uri.parse(ApiConstants.orderById(orderId));

    print('🌐 Making fetch order by ID API call to: $uri');
    print('🔐 Authorization header: $authHeader');

    final response = await http.get(uri, headers: headers);

    print('📥 Fetch Order API Response Status: ${response.statusCode}');
    print('📥 Fetch Order API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return OrderDetailModel.fromJson(data);
    } else if (response.statusCode == 403) {
      throw Exception(
        'Access denied. You don\'t have permission to view this order.',
      );
    } else if (response.statusCode == 404) {
      throw Exception('Order not found.');
    } else {
      throw Exception('Failed to fetch order: ${response.statusCode}');
    }
  }
}
