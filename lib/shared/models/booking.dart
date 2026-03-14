import 'worker.dart';

/// Represents a customer booking in the marketplace.
class Booking {
  final String id;
  final Worker worker;
  final String bookingDate;
  final String timeSlot;
  final int hours;
  final String address;
  final double totalAmount;
  final double platformFee;
  final double discountAmount;
  final String status;
  final String bookingRef;
  final DateTime createdAt;
  final String? message;
  final bool? simulated;

  const Booking({
    required this.id,
    required this.worker,
    required this.bookingDate,
    required this.timeSlot,
    required this.hours,
    required this.address,
    required this.totalAmount,
    required this.platformFee,
    required this.discountAmount,
    required this.status,
    required this.bookingRef,
    required this.createdAt,
    this.message,
    this.simulated,
  });

  /// Whether this booking was created in simulation/fallback mode.
  bool get isSimulated => simulated == true || (bookingRef.startsWith('SIM-'));

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id:             json['id']?.toString()           ?? '',
      worker:         Worker.fromJson(json['worker'] as Map<String, dynamic>),
      bookingDate:    json['booking_date']?.toString() ?? '',
      timeSlot:       json['time_slot']?.toString()    ?? '',
      hours:          (json['hours'] as num?)?.toInt() ?? 0,
      address:        json['address']?.toString()      ?? '',
      totalAmount:    (json['total_amount']    as num?)?.toDouble() ?? 0.0,
      platformFee:    (json['platform_fee']    as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      status:         json['status']?.toString()       ?? 'pending',
      bookingRef:     json['booking_ref']?.toString()  ?? '',
      createdAt:      json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      message:   json['message'] as String?,
      simulated: json['simulated'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':              id,
    'booking_date':    bookingDate,
    'time_slot':       timeSlot,
    'hours':           hours,
    'address':         address,
    'total_amount':    totalAmount,
    'platform_fee':    platformFee,
    'discount_amount': discountAmount,
    'status':          status,
    'booking_ref':     bookingRef,
    'created_at':      createdAt.toIso8601String(),
    'message':         message,
    'simulated':       simulated,
  };
}
