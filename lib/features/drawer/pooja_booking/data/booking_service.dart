import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/providers/token_provider.dart';
import 'package:temple_app/features/drawer/pooja_booking/data/booking_model.dart';

class BookingService {
  static const String _baseUrl = "http://templerun.click/api/booking/orders/";

  static Future<List<Booking>> fetchOrders(Ref ref, String filter) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    print('🔑 Authorization Token: $token'); // debug token

    if (token.isEmpty) throw Exception('User not authenticated');

    final uri = Uri.parse("$_baseUrl?filter=$filter");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };
    print('📝 Request URL: $uri');
    print('📝 Request Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('📦 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Booking>((item) => Booking.fromJson(item)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('❌ 403 Forbidden: Check user role or token validity');
    } else {
      throw Exception('⚠️ ${response.statusCode} ${response.body}');
    }
  }


  static Future<Booking> fetchBookingById(Ref ref, int id) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final uri = Uri.parse("$_baseUrl$id/");

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data);
    } else {
      throw Exception('⚠️ ${response.statusCode} ${response.body}');
    }
  }
}


final bookingOrdersProvider =
    AutoDisposeFutureProvider.family<List<Booking>, String>((
      ref,
      filter,
    ) async {
      return BookingService.fetchOrders(ref, filter);
    });

final bookingDetailProvider =
    AutoDisposeFutureProvider.family<Booking, int>((ref, bookingId) async {
  return BookingService.fetchBookingById(ref, bookingId);
});

