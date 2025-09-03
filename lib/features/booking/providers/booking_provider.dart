import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../data/booking_pooja_model.dart';
import '../data/cart_model.dart';
import '../data/checkout_model.dart';

// Provider for adding to cart
final addToCartProvider =
    FutureProvider.family<
      BookingCartResponse,
      ({
        String poojaId,
        List<int> userListIds,
        bool status,
        String? agentCode,
        String? selectedDate,
        int? specialPoojaDateId,
      })
    >((ref, params) async {
      final repository = ref.read(bookingRepositoryProvider);
      return await repository.addToCart(
        poojaId: params.poojaId,
        userListIds: params.userListIds,
        status: params.status,
        agentCode: params.agentCode,
        selectedDate: params.selectedDate,
        specialPoojaDateId: params.specialPoojaDateId,
      );
    });

// Alternative provider with different name to avoid caching issues
final bookPoojaProvider =
    FutureProvider.family<
      BookingCartResponse,
      ({
        String poojaId,
        List<int> userListIds,
        bool status,
        String? agentCode,
        String? selectedDate,
        int? specialPoojaDateId,
      })
    >((ref, params) async {
      final repository = ref.read(bookingRepositoryProvider);
      return await repository.addToCart(
        poojaId: params.poojaId,
        userListIds: params.userListIds,
        status: params.status,
        agentCode: params.agentCode,
        selectedDate: params.selectedDate,
        specialPoojaDateId: params.specialPoojaDateId,
      );
    });

// Simple provider to avoid type inference issues
final simpleBookPoojaProvider =
    FutureProvider.family<BookingCartResponse, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.read(bookingRepositoryProvider);
      return await repository.addToCart(
        poojaId: params['poojaId'] as String,
        userListIds: params['userListIds'] as List<int>,
        status: params['status'] as bool,
        agentCode: params['agentCode'] as String?,
        selectedDate: params['selectedDate'] as String?,
        specialPoojaDateId: params['specialPoojaDateId'] as int?,
      );
    });

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

final bookingPoojaProvider = FutureProvider.family<BookingPooja, int>((
  ref,
  poojaId,
) async {
  final repository = ref.read(bookingRepositoryProvider);
  return await repository.getBookingPooja(poojaId);
});

// Provider for getting cart
final cartProvider = FutureProvider<CartResponse>((ref) async {
  final repository = ref.read(bookingRepositoryProvider);
  return await repository.getCart();
});

// Provider for checkout
final checkoutProvider = FutureProvider<CheckoutResponse>((ref) async {
  final repository = ref.read(bookingRepositoryProvider);
  return await repository.checkout();
});
