import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../data/booking_pooja_model.dart';

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
