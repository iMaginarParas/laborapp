import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/booking/providers/booking_providers.dart';
import 'package:flutter_app/shared/models/booking.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:intl/intl.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("My Bookings", style: AppTextStyles.h2),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        data: (bookings) => bookings.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 80, color: AppColors.muted),
                const SizedBox(height: 24),
                Text("Connection Error", style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Text(
                  "We couldn't reach the server. Please ensure the backend is running and you have an active connection.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: PrimaryButton(
                    text: "Retry Connection",
                    onPressed: () => ref.invalidate(bookingsProvider),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Debug: ${e.toString().split('\n').first}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text("📅", style: TextStyle(fontSize: 60))),
            ),
            const SizedBox(height: 32),
            Text("No bookings done", style: AppTextStyles.h2),
            const SizedBox(height: 12),
            Text(
              "Experience the best doorstep services.\nBook your first worker now!",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 56,
              child: PrimaryButton(
                text: "Find Workers",
                onPressed: () {
                  // This is a bit hacky on desktop/web without a global controller, 
                  // but we can just pop to home or similar if needed.
                  // For now, advising the user to use the search tab.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleBlue,
                child: Text(booking.worker.categories.first.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.worker.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(booking.worker.categories.first.name, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.calendar_today_outlined, DateFormat('MMM dd, yyyy').format(DateTime.parse(booking.bookingDate))),
              _buildInfoItem(Icons.access_time, booking.timeSlot),
              _buildInfoItem(Icons.payments_outlined, "₹${booking.totalAmount.toInt()}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.successGreen;
        bgColor = AppColors.greenBG;
        break;
      case 'pending':
        color = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        break;
      case 'cancelled':
        color = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        break;
      default:
        color = AppColors.primaryBlue;
        bgColor = AppColors.paleBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }
}
