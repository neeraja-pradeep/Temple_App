import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/global_api_notifer/data/repository/sync_repository.dart';
import 'package:temple_app/features/shop/delivery/data/model/address_model.dart';
import 'package:temple_app/features/shop/delivery/data/repositories/delivery_repository.dart';
import 'package:temple_app/features/shop/delivery/data/repositories/order_repository.dart';

final addressRepositoryProvider = Provider((ref) => AddressRepository());

final addressListProvider =
    StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressModel>>>((
      ref,
    ) {
      final repo = ref.watch(addressRepositoryProvider);
      return AddressNotifier(ref,repo);
    });

class AddressNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
   final Ref ref;
  final AddressRepository repository;
  final repo = SyncRepository();

  AddressNotifier(this.ref,this.repository) : super(const AsyncValue.loading()) {
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
      await checkAddressUpdateAndSync(repo, ref);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      await repository.addAddress(address);
      await fetchAddresses();
      await checkAddressUpdateAndSync(repo, ref);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> selectAddress(int id) async {
    try {
      await repository.selectAddress(id);
      await fetchAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAddress(int id) async {
    log("Deleting address with id: $id");
    try {
      await repository.deleteAddress(id);
      await fetchAddresses();
      await checkAddressUpdateAndSync(repo, ref);
    } catch (e) {
      // Don't set state to error - let the UI handle the exception with dialog
      rethrow;
    }
  }
}

final selectedPaymentProvider = StateProvider<int>(
  (ref) => -1,
); // -1 means none selected

// Orders
final orderRepositoryProvider = Provider((ref) => OrderRepository());

final orderDetailProvider = FutureProvider.family((ref, int orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.fetchOrderById(orderId);
});
