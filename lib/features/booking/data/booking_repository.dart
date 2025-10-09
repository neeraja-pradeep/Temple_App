import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_pooja_model.dart';
import 'cart_model.dart';
import 'checkout_model.dart';
import '../../../core/services/complete_token_service.dart';

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
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print(
        '🌐 Making get booking pooja API call to: $baseUrl/booking/poojas/$poojaId',
      );
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(
        Uri.parse('$baseUrl/booking/poojas/$poojaId'),
        headers: headers,
      );

      print('📥 Get Booking Pooja API Response Status: ${response.statusCode}');
      print('📥 Get Booking Pooja API Response Body: ${response.body}');

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
        // Special pooja - send special_pooja_date_ids (API expects an array)
        requestBody['special_pooja_date_ids'] = [specialPoojaDateId];
        // Maintain legacy key for backward compatibility if the backend still accepts it
        requestBody['special_pooja_date_id'] = specialPoojaDateId.toString();
        print(
          '🎯 Special Pooja detected - using special_pooja_date_ids: $specialPoojaDateId',
        );
      } else if (selectedDate != null) {
        // Regular pooja - send selected_dates (API expects an array)
        requestBody['selected_dates'] = [selectedDate];
        // Maintain legacy key for backward compatibility if the backend still accepts it
        requestBody['selected_date'] = selectedDate;
        print('📅 Regular Pooja detected - using selected_dates: $selectedDate');
      } else {
        throw Exception(
          'Either selected_date or special_pooja_date_id must be provided',
        );
      }

      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 API Call - POST $baseUrl/booking/cart/');
      print('🔐 Authorization header: $authHeader');
      print('📤 Request Payload: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/booking/cart/'),
        headers: headers,
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
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 API Call - GET $baseUrl/booking/cart/');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(
        Uri.parse('$baseUrl/booking/cart/'),
        headers: headers,
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
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 API Call - POST $baseUrl/booking/checkout/');
      print('🔐 Authorization header: $authHeader');

      final response = await http.post(
        Uri.parse('$baseUrl/booking/checkout/'),
        headers: headers,
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
