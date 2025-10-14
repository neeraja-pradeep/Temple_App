import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/features/shop/delivery/data/model/address_model.dart';

import '../../../../../core/services/complete_token_service.dart';

class AddressRepository {
  AddressRepository({http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl = ApiConstants.addresses;
  final http.Client _client;

  Future<Box<AddressModel>> _openBox() {
    return Hive.openBox<AddressModel>('addressBox');
  }

  Future<Map<String, String>> _requireAuthHeaders({
    bool includeJsonContentType = false,
  }) async {
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception(
        'No valid authentication token found. Please login again.',
      );
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': authHeader,
    };

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  void _logRequest(
    String verb,
    Uri uri,
    Map<String, String> headers, {
    Object? body,
  }) {
    print('🌐 $verb $uri');
    print('🔐 Authorization header: ${headers['Authorization']}');
    if (body != null) {
      print('📤 Request body: ${body is String ? body : jsonEncode(body)}');
    }
  }

  void _logResponse(String label, http.Response response) {
    print('📥 $label Response Status: ${response.statusCode}');
    print('📥 $label Response Body: ${response.body}');
  }

  String _extractErrorMessage(http.Response response, String fallbackMessage) {
    if (response.body.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final collected = <String>[];

          for (final entry in decoded.entries) {
            final value = entry.value;
            if (value is List && value.isNotEmpty) {
              collected.add(value.first.toString());
            } else if (value is String && value.isNotEmpty) {
              collected.add(value);
            }
          }

          if (collected.isNotEmpty) {
            return collected.join('\n');
          }
        } else if (decoded is List && decoded.isNotEmpty) {
          return decoded.first.toString();
        } else if (decoded is String && decoded.isNotEmpty) {
          return decoded;
        }
      } catch (_) {
        // Ignore JSON parsing issues and fall back to status-based messages.
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'Invalid request. Please check the details and try again.';
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return "You don't have permission to perform this action.";
      case 404:
        return 'Address not found.';
      case 409:
        return 'Address already exists.';
      case 500:
        return 'Server error occurred. Please try again later.';
      default:
        return fallbackMessage;
    }
  }

  /// Fetch Addresses (API + Cache)
  Future<List<AddressModel>> fetchAddresses() async {
    final box = await _openBox();
    try {
      final headers = await _requireAuthHeaders();
      final uri = Uri.parse(baseUrl);

      _logRequest('GET', uri, headers);

      final response = await _client.get(uri, headers: headers);

      _logResponse('Addresses API', response);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final addresses = data.map((e) => AddressModel.fromJson(e)).toList();

        await box.clear();
        for (final addr in addresses) {
          await box.put(addr.id, addr);
        }

        log('✅ Fetched ${addresses.length} addresses from API.');
        return addresses;
      } else {
        log(
          '⚠️ Failed to fetch addresses. Status code: ${response.statusCode}',
        );
        throw Exception('Failed to fetch addresses');
      }
    } catch (e) {
      log('⚠️ Fetch failed: $e. Returning cached data.');
      return box.values.toList();
    }
  }

  /// Add New Address
  Future<AddressModel> addAddress(AddressModel address) async {
    final box = await _openBox();

    final payload = {
      'name': address.name,
      'street': address.street,
      'city': address.city,
      'state': address.state.isNotEmpty ? address.state : 'N/A',
      'country': address.country.isNotEmpty ? address.country : 'India',
      'pincode': address.pincode,
      'selection': address.selection,
      'phone_number': address.phonenumber,
    };

    try {
      final headers = await _requireAuthHeaders(includeJsonContentType: true);
      final uri = Uri.parse(baseUrl);

      _logRequest('POST', uri, headers, body: payload);

      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      _logResponse('Add Address API', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAddress = AddressModel.fromJson(jsonDecode(response.body));

        await box.put(newAddress.id, newAddress);

        log('✅ Address added successfully: ${newAddress.name}');
        return newAddress;
      } else {
        final message = _extractErrorMessage(response, 'Failed to add address');
        log('❌ Add failed. Status: ${response.statusCode}, Message: $message');
        throw AddressRepositoryException(message);
      }
    } catch (e) {
      log('❌ Exception while adding: $e');
      if (e is AddressRepositoryException) {
        rethrow;
      }
      throw AddressRepositoryException(
        'Network error occurred while adding address. Please try again.',
      );
    }
  }

  /// Update Existing Address
  Future<AddressModel> updateAddress(AddressModel address) async {
    final box = await _openBox();

    final payload = {
      'id': address.id,
      'name': address.name,
      'street': address.street,
      'city': address.city,
      'state': address.state.isNotEmpty ? address.state : 'N/A',
      'country': address.country.isNotEmpty ? address.country : 'India',
      'pincode': address.pincode,
      'selection': address.selection,
      'phone_number': address.phonenumber,
    };

    try {
      final headers = await _requireAuthHeaders(includeJsonContentType: true);
      final uri = Uri.parse('$baseUrl${address.id}/');

      _logRequest('PATCH', uri, headers, body: payload);

      final response = await _client.patch(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      _logResponse('Update Address API', response);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updatedAddress = AddressModel.fromJson(
          response.statusCode == 204
              ? address.toJson()
              : jsonDecode(response.body),
        );

        await box.put(updatedAddress.id, updatedAddress);

        log('✅ Address with ID ${updatedAddress.id} updated.');
        return updatedAddress;
      } else {
        final message = _extractErrorMessage(
          response,
          'Failed to update address',
        );
        log(
          '❌ Update failed. Status: ${response.statusCode}, Message: $message',
        );
        throw AddressRepositoryException(message);
      }
    } catch (e) {
      log('❌ Exception while updating: $e');
      if (e is AddressRepositoryException) {
        rethrow;
      }
      throw AddressRepositoryException(
        'Network error occurred while updating address. Please try again.',
      );
    }
  }

  /// Select Address
  Future<void> selectAddress(int id) async {
    final box = await _openBox();
    try {
      final headers = await _requireAuthHeaders(includeJsonContentType: true);
      final body = {'id': id, 'selection': true};
      final uri = Uri.parse(ApiConstants.addressById(id));

      _logRequest('PATCH', uri, headers, body: body);

      final response = await _client.patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      _logResponse('Select Address API', response);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final addresses = box.values.toList();
        for (final addr in addresses) {
          addr.selection = addr.id == id;
          await box.put(addr.id, addr);
        }
        log('✅ Address with ID $id selected.');
      } else {
        log(
          '❌ Failed select. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to select address');
      }
    } catch (e) {
      log('❌ Exception while selecting: $e');
      rethrow;
    }
  }

  /// Delete Address
  Future<void> deleteAddress(int id) async {
    final box = await _openBox();
    try {
      final headers = await _requireAuthHeaders(includeJsonContentType: true);
      final uri = Uri.parse(ApiConstants.addressById(id));

      _logRequest('DELETE', uri, headers);

      final response = await _client.delete(uri, headers: headers);

      _logResponse('Delete Address API', response);

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('error')) {
            log('❌ Delete failed. Error: ${responseData['error']}');
            throw Exception(responseData['error']);
          }
        } catch (e) {
          log('⚠️ Could not parse response body: $e');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        await box.delete(id);
        log('✅ Address with ID $id deleted.');
      } else {
        log(
          '❌ Delete failed. Status: ${response.statusCode}, Body: ${response.body}',
        );

        String errorMessage = 'Failed to delete address';
        if (response.body.isNotEmpty) {
          try {
            final responseData = jsonDecode(response.body);
            if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            }
          } catch (_) {
            errorMessage = _statusCodeFallback(response.statusCode);
          }
        } else {
          errorMessage = _statusCodeFallback(response.statusCode);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ Exception while deleting: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred while deleting address');
    }
  }

  String _statusCodeFallback(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please try again';
      case 403:
        return "You don't have permission to delete this address";
      case 404:
        return 'Address not found';
      case 500:
        return 'Server error occurred while deleting address';
      default:
        return 'Failed to delete address';
    }
  }
}

class AddressRepositoryException implements Exception {
  AddressRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
