import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/worker.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onTap;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Pic / Emoji
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Hero(
                      tag: 'worker_emoji_${worker.id}',
                      child: Text(
                        worker.categories.isNotEmpty ? worker.categories.first.emoji : "👷",
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  if (worker.isAvailable)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                worker.name,
                                style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                worker.categories.isNotEmpty 
                                  ? worker.categories.first.name 
                                  : "Skilled Worker",
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${worker.hourlyRate.toInt()}/hr",
                              style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Bottom Row: Rating, Distance, Chat
                    Row(
                      children: [
                        // Distance
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              "1.2 km",
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              worker.rating.toString(),
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Chat Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.paleBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, color: AppColors.primaryBlue, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "Chat",
                                style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
