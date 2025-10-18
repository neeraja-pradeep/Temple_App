import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/core/providers/token_provider.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';

class StoreOrderService {
  static const _boxPrefix = 'store_orders';
  static const _allStatusKey = 'all';
  static const String baseBoxName = 'store_orders_all';
  static const List<String> _knownStatuses = [
    'pending',
    'delivered',
    'cancelled',
    'completed',
    'upcoming'
  ];
  static final Set<String> _trackedBoxes = {baseBoxName};

  /// Returns all cache box names currently tracked.
  static List<String> cacheBoxNames() {
    final names = <String>{baseBoxName, ..._trackedBoxes};
    for (final status in _knownStatuses) {
      names.add(_boxName(status));
    }
    return List.unmodifiable(names);
  }

  static String? _normalizeStatus(String? status) {
    final trimmed = status?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final normalized = trimmed.toLowerCase();
    return normalized == _allStatusKey ? null : normalized;
  }

  static String _boxName(String? normalizedStatus) {
    if (normalizedStatus == null) return baseBoxName;
    return '${_boxPrefix}_$normalizedStatus';
  }

  Future<StoreOrderResponse> fetchOrdersPage(
    Ref ref, {
    String? status,
    String? pageUrl,
  }) async {
    final normalizedStatus = _normalizeStatus(status);
    final boxName = _boxName(normalizedStatus);
    _trackedBoxes.add(boxName);

    final box = await Hive.openBox<StoreOrder>(boxName);

    // Cached data
    StoreOrderResponse? cachedResponse;
    if (box.isNotEmpty && pageUrl == null) {
      debugPrint('[StoreOrderService] Using cached results for $boxName');
      cachedResponse = StoreOrderResponse(
        count: box.values.length,
        results: box.values.toList(),
        next: null,
        previous: null,
      );
    }

    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    // 🔗 Build the URL
    late Uri uri;
    if (pageUrl != null) {
      uri = Uri.parse(pageUrl);
    } else {
      // filter-based API
      final baseUri = Uri.parse(ApiConstants.orders);
      uri = normalizedStatus == null
          ? baseUri
          : baseUri.replace(queryParameters: {'filter': normalizedStatus});
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      debugPrint('[StoreOrderService] ❌ HTTP ${response.statusCode} for $uri');
      if (cachedResponse != null) {
        debugPrint('⚠️ Serving cached data for $boxName');
        return cachedResponse;
      }
      throw Exception('Failed to fetch store orders');
    }

    // 🔍 Parse
    final data = jsonDecode(response.body);
    final page = StoreOrderResponse.fromJson(data);

    // Sort latest first
    final sortedResults = List<StoreOrder>.from(page.results)
      ..sort((a, b) =>
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    // Cache only the first page per filter
    if (pageUrl == null) {
      await box.clear();
      for (final order in sortedResults) {
        await box.put(order.id, order);
      }
    }

    // Return with next/prev
    return StoreOrderResponse(
      count: page.count,
      next: page.next,
      previous: page.previous,
      results: sortedResults,
    );
  }
}

// 🪣 Provider
final storeOrderServiceProvider =
    Provider<StoreOrderService>((ref) => StoreOrderService());

final storeOrdersPageProvider = FutureProvider.autoDispose
    .family<StoreOrderResponse, (String status, String? pageUrl)>(
  (ref, params) async {
    final (status, pageUrl) = params;
    final service = ref.read(storeOrderServiceProvider);
    return service.fetchOrdersPage(ref, status: status, pageUrl: pageUrl);
  },
);
