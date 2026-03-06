import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/widgets/badge_pill.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:flutter_app/features/booking/presentation/booking_screen.dart';

class WorkerProfileScreen extends ConsumerWidget {
  final Worker worker;

  const WorkerProfileScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context),
            _buildStatsRow(),
            _buildContent(),
            const SizedBox(height: 120), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkBlue,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            alignment: Alignment.center,
            child: Text(worker.categories.first.emoji, style: const TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 20),
          Text(
            worker.name, 
            style: AppTextStyles.h1.copyWith(color: AppColors.white, fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            "${worker.categories.map((e) => e.name).join(' & ')} Decorator", 
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightBlue.withOpacity(0.8)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _HeaderBadge(label: "Verified ID", icon: Icons.check, color: AppColors.white),
              const SizedBox(width: 12),
              _HeaderBadge(label: worker.city, icon: Icons.location_on, color: Colors.redAccent),
              const SizedBox(width: 12),
              if (worker.isAvailable)
                const _HeaderBadge(label: "Available", icon: Icons.bolt, color: Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem("Jobs Done", "128"),
            _buildDivider(),
            _buildStatItem("Rating", "${worker.rating}★"),
            _buildDivider(),
            _buildStatItem("Experience", "${worker.experienceYears} yrs"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.text, fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border.withOpacity(0.5),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About", style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Text(
            worker.bio,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.muted, 
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          Text("Skills", style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: worker.skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(s.skillName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "₹${worker.hourlyRate.toInt()}/hr ", 
                        style: AppTextStyles.h3.copyWith(fontSize: 22, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                Text("Min. 2 hours", style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 180,
              height: 56,
              child: PrimaryButton(
                text: "Book Now —", 
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(worker: worker),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _HeaderBadge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
