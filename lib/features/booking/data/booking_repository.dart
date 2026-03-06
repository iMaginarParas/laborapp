import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/booking.dart';

class BookingRepository {
  final DioClient _client;

  BookingRepository(this._client);

  Future<Booking> createBooking({
    required String workerId,
    required int categoryId,
    required String date,
    required String timeSlot,
    required int hours,
    required String address,
  }) async {
    final response = await _client.post(ApiConstants.bookings, data: {
      'worker_id': workerId,
      'category_id': categoryId,
      'booking_date': date,
      'time_slot': timeSlot,
      'hours': hours,
      'address': address,
    });
    
    return Booking.fromJson(response.data);
  }

  Future<List<Booking>> getBookings() async {
    final response = await _client.get(ApiConstants.bookings);
    return (response.data as List).map((e) => Booking.fromJson(e)).toList();
  }
}
