import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'booking_model.dart';
import '../../../../core/providers/token_provider.dart';

class BookingService {
  static const String _baseUrl = "http://templerun.click/api/booking/orders/";

  // Fetch all bookings
  static Future<List<Booking>> fetchOrders(Ref ref, String filter) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final box = await Hive.openBox<Booking>('bookingBox');

    // ✅ Return cached bookings first
    if (box.isNotEmpty) {
      print('📦 Returning cached bookings (${box.length})');
      return box.values.toList();
    }

    // API call
    final uri = Uri.parse("$_baseUrl?filter=$filter");
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final bookings = data.map<Booking>((item) => Booking.fromJson(item)).toList();

      // Cache in Hive
      await box.clear();
      for (var booking in bookings) {
        await box.put(booking.id, booking);
      }
      print('💾 Cached ${bookings.length} bookings');
      return bookings;
    } else {
      throw Exception('⚠️ ${response.statusCode} ${response.body}');
    }
  }

  // Fetch single booking by ID (with caching)
  static Future<Booking> fetchBookingById(Ref ref, int id) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final box = await Hive.openBox<Booking>('bookingBox');

    // ✅ Return cached if exists
    if (box.containsKey(id)) {
      print('📦 Returning cached booking $id');
      return box.get(id)!;
    }

    final uri = Uri.parse("$_baseUrl$id/");
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final booking = Booking.fromJson(data);
      await box.put(booking.id, booking); // cache
      print('💾 Cached booking ${booking.id}');
      return booking;
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

