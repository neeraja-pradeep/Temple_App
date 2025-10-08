import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/providers/token_provider.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';
class StoreOrderService {
  final String baseUrl = "http://templerun.click/api/ecommerce/orders/";

  Future<StoreOrderResponse> fetchOrders(Ref ref, {String? status}) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final url = status != null ? "$baseUrl?status=$status" : baseUrl;
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StoreOrderResponse.fromJson(data);
    } else {
      throw Exception("Failed to fetch store orders: ${response.statusCode}");
    }
  }
}



// service provider
final storeOrderServiceProvider =
    Provider<StoreOrderService>((ref) => StoreOrderService());

final storeOrdersProvider = FutureProvider.autoDispose
    .family<StoreOrderResponse, String>((ref, status) async {
  final service = ref.read(storeOrderServiceProvider);

  if (status.toLowerCase() == "delivered") {
    return service.fetchOrders(ref, status: "delivered");
  } else if (status.toLowerCase() == "cancelled") {
    return service.fetchOrders(ref, status: "cancelled");
  } 
  else if (status.toLowerCase() == "pending") {
    return service.fetchOrders(ref, status: "pending");
  } 
  else {
    // default upcoming (all)
    return service.fetchOrders(ref);
  }
});


