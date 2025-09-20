import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple/core/constants/api_constants.dart';
import 'package:temple/features/shop/delivery/data/model/address_model.dart';

class AddressRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/ecommerce/address/";

  Future<Box<AddressModel>> _openBox() async {
    return await Hive.openBox<AddressModel>('addressBox');
  }

  /// Fetch Addresses (API + Cache)
  Future<List<AddressModel>> fetchAddresses() async {
    final box = await _openBox();
    try {
      final response = await http.get(Uri.parse(baseUrl));
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
        log("⚠️ Failed to fetch addresses. Status code: ${response.statusCode}");
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAddress = AddressModel.fromJson(jsonDecode(response.body));

        // ✅ Save with id as key
        await box.put(newAddress.id, newAddress);

        log("✅ Address added successfully: ${newAddress.name}");
        return newAddress;
      } else {
        log("❌ Add failed. Status: ${response.statusCode}, Body: ${response.body}");
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
      final response = await http.patch(
        Uri.parse("$baseUrl${address.id}/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updatedAddress = AddressModel.fromJson(
          response.statusCode == 204 ? address.toJson() : jsonDecode(response.body),
        );

        await box.put(updatedAddress.id, updatedAddress);

        log("✅ Address with ID ${updatedAddress.id} updated.");
        return updatedAddress;
      } else {
        log("❌ Update failed. Status: ${response.statusCode}, Body: ${response.body}");
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
      final response = await http.patch(
          Uri.parse('$baseUrl$id/'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "selection": true}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final addresses = box.values.toList();
        for (var addr in addresses) {
          addr.selection = addr.id == id;
          await box.put(addr.id, addr);
        }
        log("✅ Address with ID $id selected.");
      } else {
        log("❌ Failed select. Status: ${response.statusCode}, Body: ${response.body}");
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
      final response = await http.delete(Uri.parse("$baseUrl$id/"));

      if (response.statusCode == 200 || response.statusCode == 204) {
        await box.delete(id); // ✅ delete by id key
        log("✅ Address with ID $id deleted.");
      } else {
        log("❌ Delete failed. Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to delete address");
      }
    } catch (e) {
      log("❌ Exception while deleting: $e");
      rethrow;
    }
  }
}
