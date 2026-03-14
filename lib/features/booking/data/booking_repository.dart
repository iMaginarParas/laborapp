import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/booking.dart';

/// Handles booking-related network operations.
class BookingRepository {
  final DioClient _client;

  BookingRepository(this._client);

  /// Submits a new booking request and returns the created [Booking].
  Future<Booking> createBooking({
    required String workerId,
    required int categoryId,
    required String date,
    required String timeSlot,
    required int hours,
    required String address,
  }) async {
    final response = await _client.post(ApiConstants.bookings, data: {
      'worker_id':    workerId,
      'category_id':  categoryId,
      'booking_date': date,
      'time_slot':    timeSlot,
      'hours':        hours,
      'address':      address,
    });
    
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  /// Returns all bookings for the authenticated user.
  Future<List<Booking>> getBookings() async {
    final response = await _client.get(ApiConstants.bookings);
    return (response.data as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single booking by its [id].
  Future<Booking> getBookingById(String id) async {
    final response = await _client.get('${ApiConstants.bookings}/$id');
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }
}
