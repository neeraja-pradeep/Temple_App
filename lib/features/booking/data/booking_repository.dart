import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_pooja_model.dart';

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
}
