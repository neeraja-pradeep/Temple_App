import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/core/providers/token_provider.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';

class StoreOrderService {
  final String hiveBoxName = 'storeOrders';

  Future<StoreOrderResponse> fetchOrders(Ref ref, {String? status}) async {
    final box = await Hive.openBox<StoreOrder>('store_orders');

    // 🐝 Return cached orders first if exists
    if (box.isNotEmpty) {
      print('📦 Returning cached store orders (${box.values.length})');
      return StoreOrderResponse(
        count: box.values.length,
        results: box.values.toList(),
        next: null,
        previous: null,
      );
    }

    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final baseUrl = ApiConstants.orders;
    final url = status != null ? "$baseUrl?status=$status" : baseUrl;

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final resp = StoreOrderResponse.fromJson(data);

      // 🐝 Cache orders in Hive
      await box.clear();
      for (var order in resp.results) {
        await box.put(order.id, order);
      }

      return resp;
    } else {
      throw Exception("Failed to fetch store orders: ${response.statusCode}");
    }
  }
}

// Providers
final storeOrderServiceProvider = Provider<StoreOrderService>((ref) => StoreOrderService());

final storeOrdersProvider =
    FutureProvider.autoDispose.family<StoreOrderResponse, String>((ref, status) async {
  final service = ref.read(storeOrderServiceProvider);
  return service.fetchOrders(ref, status: status);
});
