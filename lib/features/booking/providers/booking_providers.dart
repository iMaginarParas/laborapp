import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/home_providers.dart';
import '../data/booking_repository.dart';

final bookingRepositoryProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return BookingRepository(client);
});

final bookingLoadingProvider = StateProvider<bool>((ref) => false);

final bookingsProvider = FutureProvider((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookings();
});
