import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String workerName;
  final String date;
  final String time;
  final String reference;

  const BookingSuccessScreen({
    super.key,
    required this.workerName,
    required this.date,
    required this.time,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Success Icon
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.greenBG.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("🥳", style: TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                "Booking Confirmed!",
                style: AppTextStyles.h1.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                "$workerName will arrive at your address\non $date at $time",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Reference Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Booking Reference",
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reference.startsWith("#") ? reference : "#$reference",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.darkBlue,
                        fontSize: 24,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Action Buttons
              PrimaryButton(
                text: "Track Worker Live 📍",
                onPressed: () {
                  // TODO: Implement live tracking
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Back to Home",
                    style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
