import 'worker.dart';

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

  Booking({
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
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      worker: Worker.fromJson(json['worker']),
      bookingDate: json['booking_date'],
      timeSlot: json['time_slot'],
      hours: json['hours'],
      address: json['address'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      status: json['status'],
      bookingRef: json['booking_ref'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
