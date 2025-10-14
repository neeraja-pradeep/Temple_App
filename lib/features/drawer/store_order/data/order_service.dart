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
  static const List<String> _knownStatuses = ['pending', 'delivered', 'cancelled'];
  static final Set<String> _trackedBoxes = {baseBoxName};

  /// Returns the list of cache box names currently in use.
  static List<String> cacheBoxNames() {
    final names = <String>{baseBoxName, ..._trackedBoxes};
    for (final status in _knownStatuses) {
      names.add(_boxName(status));
    }
    return List.unmodifiable(names);
  }

  static String? _normalizeStatus(String? status) {
    final trimmed = status?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final normalized = trimmed.toLowerCase();
    return normalized == _allStatusKey ? null : normalized;
  }

  static String _boxName(String? normalizedStatus) {
    if (normalizedStatus == null) {
      return baseBoxName;
    }
    return '${_boxPrefix}_$normalizedStatus';
  }

  Future<StoreOrderResponse> fetchOrders(
    Ref ref, {
    String? status,
  }) async {
    final normalizedStatus = _normalizeStatus(status);
    final boxName = _boxName(normalizedStatus);
    _trackedBoxes.add(boxName);

    final box = await Hive.openBox<StoreOrder>(boxName);

    StoreOrderResponse? cachedResponse;
    if (box.isNotEmpty) {
      debugPrint(
        '[StoreOrderService] Serving cached results for $boxName '
        '(${box.values.length} items)',
      );
      cachedResponse = StoreOrderResponse(
        count: box.values.length,
        results: box.values.toList(),
        next: null,
        previous: null,
      );
    }

    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final baseUri = Uri.parse(ApiConstants.orders);
    final initialUri = normalizedStatus == null
        ? baseUri
        : baseUri.replace(queryParameters: {'status': normalizedStatus});

    final aggregatedResults = <StoreOrder>[];
    String? nextUrl = initialUri.toString();
    String? previous;
    int? totalCount;
    bool fetchFailed = false;

    while (nextUrl != null) {
      final response = await http.get(
        Uri.parse(nextUrl),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        fetchFailed = true;
        debugPrint(
          '[StoreOrderService] Failed fetching $nextUrl '
          '(HTTP ${response.statusCode})',
        );
        break;
      }

      final data = jsonDecode(response.body);
      final page = StoreOrderResponse.fromJson(data);

      totalCount = page.count;
      previous ??= page.previous;
      aggregatedResults.addAll(page.results);

      nextUrl = page.next;
    }

    if (!fetchFailed) {
      final sortedResults = List<StoreOrder>.from(aggregatedResults)
        ..sort(
          (a, b) => DateTime.parse(b.createdAt)
              .compareTo(DateTime.parse(a.createdAt)),
        );

      await box.clear();
      for (final order in sortedResults) {
        await box.put(order.id, order);
      }

      return StoreOrderResponse(
        count: totalCount ?? sortedResults.length,
        next: null,
        previous: previous,
        results: sortedResults,
      );
    }

    if (cachedResponse != null) {
      debugPrint(
        '⚠️ Failed to fetch remote orders; serving cached data for $boxName.',
      );
      return cachedResponse;
    }

    throw Exception('Failed to fetch store orders');
  }
}

// Providers
final storeOrderServiceProvider = Provider<StoreOrderService>((ref) => StoreOrderService());

final storeOrdersProvider =
    FutureProvider.autoDispose.family<StoreOrderResponse, String>((ref, status) async {
  final service = ref.read(storeOrderServiceProvider);
  return service.fetchOrders(ref, status: status);
});
