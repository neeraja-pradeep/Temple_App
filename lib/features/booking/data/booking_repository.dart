import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_pooja_model.dart';
import 'cart_model.dart';
import 'checkout_model.dart';

// Booking cart response model
class BookingCartResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final int statusCode;

  BookingCartResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory BookingCartResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    return BookingCartResponse(
      success: json['success'] ?? (statusCode >= 200 && statusCode < 300),
      message:
          json['message'] ??
          (statusCode >= 200 && statusCode < 300 ? 'Success' : 'Failed'),
      data: json['data'],
      statusCode: statusCode,
    );
  }
}

class BookingRepository {
  static const String baseUrl = 'http://templerun.click/api';

  Future<BookingPooja> getBookingPooja(int poojaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/booking/poojas/$poojaId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        return BookingPooja.fromJson(jsonData);
      } else {
        throw Exception('Failed to load booking pooja: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load booking pooja: $e');
    }
  }

  Future<BookingCartResponse> addToCart({
    required String poojaId,
    required List<int> userListIds,
    bool status = false,
    String? agentCode,
    String? selectedDate,
    int? specialPoojaDateId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'pooja_id': poojaId,
        'user_list_ids': userListIds,
        'status': status,
      };

      // Add agent code if provided
      if (agentCode != null && agentCode.isNotEmpty) {
        requestBody['agent_code'] = agentCode;
      }

      // Add date field based on pooja type
      if (specialPoojaDateId != null) {
        // Special pooja - send special_pooja_date_id
        requestBody['special_pooja_date_id'] = specialPoojaDateId.toString();
        print(
          '🎯 Special Pooja detected - using special_pooja_date_id: $specialPoojaDateId',
        );
      } else if (selectedDate != null) {
        // Regular pooja - send selected_date
        requestBody['selected_date'] = selectedDate;
        print('📅 Regular Pooja detected - using selected_date: $selectedDate');
      } else {
        throw Exception(
          'Either selected_date or special_pooja_date_id must be provided',
        );
      }

      print('🌐 API Call - POST $baseUrl/booking/cart/');
      print('📤 Request Payload: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/booking/cart/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return BookingCartResponse.fromJson(jsonData, response.statusCode);
      } else {
        throw Exception(
          'Failed to add to cart: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<CartResponse> getCart() async {
    try {
      print('🌐 API Call - GET $baseUrl/booking/cart/');

      final response = await http.get(
        Uri.parse('$baseUrl/booking/cart/'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CartResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to get cart: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to get cart: $e');
    }
  }

  Future<CheckoutResponse> checkout() async {
    try {
      print('🌐 API Call - POST $baseUrl/booking/checkout/');

      final response = await http.post(
        Uri.parse('$baseUrl/booking/checkout/'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return CheckoutResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to checkout: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to checkout: $e');
    }
  }
}
