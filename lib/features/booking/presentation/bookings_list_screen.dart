import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/booking/providers/booking_providers.dart';
import 'package:flutter_app/shared/models/booking.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/features/main_tabs/providers/navigation_providers.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/core/constants/api_constants.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_app/features/chat/presentation/chat_screen.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    
    void showWorkingOnIt() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.of(context, 'working_on_it')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("My Bookings", style: AppTextStyles.h2),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: AppColors.primaryColor),
            onPressed: showWorkingOnIt,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(bookingsProvider),
        child: bookingsAsync.when(
          data: (bookings) => bookings.isEmpty
              ? _buildEmptyState(context, ref)
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) => _buildBookingCard(context, ref, bookings[index]),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
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
                  ref.read(navigationIndexProvider.notifier).state = 1; // Switch to Search Tab
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, WidgetRef ref, Booking booking) {
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
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.chat_outlined, color: AppColors.primaryColor, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => ChatScreen(userName: booking.worker.name)),
                  );
                },
              ),
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
          if (booking.status.toLowerCase() == 'completed' && ref.read(currentRoleProvider) == UserRole.hire) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _showRatingDialog(context, ref, booking),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text("Rate Service"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, WidgetRef ref, Booking booking) {
    int rating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Rate the Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("How was your experience with ${booking.worker.name}?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  onPressed: () => setDialogState(() => rating = index + 1),
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32,
                  ),
                )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write a comment (optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                setDialogState(() => isSubmitting = true);
                try {
                  final client = ref.read(dioClientProvider);
                  await client.post(ApiConstants.reviews, data: {
                    'booking_id': booking.id,
                    'worker_id': booking.worker.id,
                    'rating': rating,
                    'comment': commentController.text,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thank you for your review!")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to submit review")),
                    );
                  }
                } finally {
                  setDialogState(() => isSubmitting = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSubmitting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
        color = AppColors.primaryColor;
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
