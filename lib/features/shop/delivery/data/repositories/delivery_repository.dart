import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/features/shop/delivery/data/model/address_model.dart';
import '../../../../../core/services/complete_token_service.dart';

class AddressRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/ecommerce/address/";

  Future<Box<AddressModel>> _openBox() async {
    return await Hive.openBox<AddressModel>('addressBox');
  }

  /// Fetch Addresses (API + Cache)
  Future<List<AddressModel>> fetchAddresses() async {
    final box = await _openBox();
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 Making fetch addresses API call to: $baseUrl');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print('📥 Addresses API Response Status: ${response.statusCode}');
      print('📥 Addresses API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final addresses = data.map((e) => AddressModel.fromJson(e)).toList();

        // Save with put() so ID matches
        await box.clear();
        for (var addr in addresses) {
          await box.put(addr.id, addr);
        }

        log("✅ Fetched ${addresses.length} addresses from API.");
        return addresses;
      } else {
        log(
          "⚠️ Failed to fetch addresses. Status code: ${response.statusCode}",
        );
        throw Exception("Failed to fetch addresses");
      }
    } catch (e) {
      log("⚠️ Fetch failed: $e. Returning cached data.");
      return box.values.toList();
    }
  }

  /// Add New Address
  Future<AddressModel> addAddress(AddressModel address) async {
    final box = await _openBox();

    final payload = {
      "name": address.name,
      "street": address.street,
      "city": address.city,
      "state": address.state.isNotEmpty ? address.state : "N/A",
      "country": address.country.isNotEmpty ? address.country : "India",
      "pincode": address.pincode,
      "selection": address.selection,
      "phone_number": address.phonenumber, // ✅ Added
    };

    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": authHeader,
      };

      print('🌐 Making add address API call to: $baseUrl');
      print('🔐 Authorization header: $authHeader');
      print('📤 Request body: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 Add Address API Response Status: ${response.statusCode}');
      print('📥 Add Address API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAddress = AddressModel.fromJson(jsonDecode(response.body));

        // ✅ Save with id as key
        await box.put(newAddress.id, newAddress);

        log("✅ Address added successfully: ${newAddress.name}");
        return newAddress;
      } else {
        log(
          "❌ Add failed. Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception("Failed to add address");
      }
    } catch (e) {
      log("❌ Exception while adding: $e");
      rethrow;
    }
  }

  /// Update Existing Address
  Future<AddressModel> updateAddress(AddressModel address) async {
    final box = await _openBox();

    final payload = {
      "id": address.id,
      "name": address.name,
      "street": address.street,
      "city": address.city,
      "state": address.state.isNotEmpty ? address.state : "N/A",
      "country": address.country.isNotEmpty ? address.country : "India",
      "pincode": address.pincode,
      "selection": address.selection,
      "phone_number": address.phonenumber, // ✅ Added
    };

    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": authHeader,
      };

      print('🌐 Making update address API call to: $baseUrl${address.id}/');
      print('🔐 Authorization header: $authHeader');
      print('📤 Request body: ${jsonEncode(payload)}');

      final response = await http.patch(
        Uri.parse("$baseUrl${address.id}/"),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 Update Address API Response Status: ${response.statusCode}');
      print('📥 Update Address API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updatedAddress = AddressModel.fromJson(
          response.statusCode == 204
              ? address.toJson()
              : jsonDecode(response.body),
        );

        await box.put(updatedAddress.id, updatedAddress);

        log("✅ Address with ID ${updatedAddress.id} updated.");
        return updatedAddress;
      } else {
        log(
          "❌ Update failed. Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception("Failed to update address");
      }
    } catch (e) {
      log("❌ Exception while updating: $e");
      rethrow;
    }
  }

  /// Select Address
  Future<void> selectAddress(int id) async {
    final box = await _openBox();
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": authHeader,
      };

      print('🌐 Making select address API call to: $baseUrl$id/');
      print('🔐 Authorization header: $authHeader');
      print('📤 Request body: ${jsonEncode({"id": id, "selection": true})}');

      final response = await http.patch(
        Uri.parse('$baseUrl$id/'),
        headers: headers,
        body: jsonEncode({"id": id, "selection": true}),
      );

      print('📥 Select Address API Response Status: ${response.statusCode}');
      print('📥 Select Address API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final addresses = box.values.toList();
        for (var addr in addresses) {
          addr.selection = addr.id == id;
          await box.put(addr.id, addr);
        }
        log("✅ Address with ID $id selected.");
      } else {
        log(
          "❌ Failed select. Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception("Failed to select address");
      }
    } catch (e) {
      log("❌ Exception while selecting: $e");
      rethrow;
    }
  }

  /// Delete Address
  Future<void> deleteAddress(int id) async {
    final box = await _openBox();
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": authHeader,
      };

      print('🌐 Making delete address API call to: $baseUrl$id/');
      print('🔐 Authorization header: $authHeader');

      final response = await http.delete(
        Uri.parse("$baseUrl$id/"),
        headers: headers,
      );

      print('📥 Delete Address API Response Status: ${response.statusCode}');
      print('📥 Delete Address API Response Body: ${response.body}');

      // Check if response body contains an error message
      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('error')) {
            // Backend returned an error message even with 200 status
            log("❌ Delete failed. Error: ${responseData['error']}");
            throw Exception(responseData['error']);
          }
        } catch (e) {
          // If JSON parsing fails, continue with normal flow
          log("⚠️ Could not parse response body: $e");
        }
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        await box.delete(id); // ✅ delete by id key
        log("✅ Address with ID $id deleted.");
      } else {
        log(
          "❌ Delete failed. Status: ${response.statusCode}, Body: ${response.body}",
        );

        // Try to parse error message from response body
        String errorMessage = "Failed to delete address";
        if (response.body.isNotEmpty) {
          try {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            }
          } catch (e) {
            // If JSON parsing fails, use status code based message
            if (response.statusCode == 400) {
              errorMessage = "Invalid request. Please try again";
            } else if (response.statusCode == 404) {
              errorMessage = "Address not found";
            } else if (response.statusCode == 403) {
              errorMessage = "You don't have permission to delete this address";
            } else if (response.statusCode == 500) {
              errorMessage = "Server error occurred while deleting address";
            }
          }
        } else {
          // No response body, use status code based message
          if (response.statusCode == 400) {
            errorMessage = "Invalid request. Please try again";
          } else if (response.statusCode == 404) {
            errorMessage = "Address not found";
          } else if (response.statusCode == 403) {
            errorMessage = "You don't have permission to delete this address";
          } else if (response.statusCode == 500) {
            errorMessage = "Server error occurred while deleting address";
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log("❌ Exception while deleting: $e");
      // If it's already an Exception with a message, rethrow it
      if (e is Exception) {
        rethrow;
      }
      // Otherwise, wrap it in a generic message
      throw Exception("Network error occurred while deleting address");
    }
  }
}
