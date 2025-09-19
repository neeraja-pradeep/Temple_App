import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/shop/delivery/data/model/address_model.dart';
import 'package:temple/features/shop/delivery/data/repositories/delivery_repository.dart';

final addressRepositoryProvider = Provider((ref) => AddressRepository());

final addressListProvider =
    StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressModel>>>((
      ref,
    ) {
      final repo = ref.watch(addressRepositoryProvider);
      return AddressNotifier(repo);
    });

class AddressNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  final AddressRepository repository;

  AddressNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    state = const AsyncValue.loading();
    try {
      final data = await repository.fetchAddresses();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    try {
      await repository.updateAddress(address);
      await fetchAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      await repository.addAddress(address);
      fetchAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> selectAddress(int id) async {
    try {
      await repository.selectAddress(id);
      fetchAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAddress(int id) async {
    log(  "Deleting address with id: $id");
    try {
      await repository.deleteAddress(id);
      fetchAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
final selectedPaymentProvider = StateProvider<int>((ref) => -1); // -1 means none selected
