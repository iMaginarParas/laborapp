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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      worker.categories.isNotEmpty ? worker.categories.first.emoji : "👷",
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  if (worker.isAvailable)
                    Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: AppTextStyles.h3.copyWith(fontSize: 17, color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      worker.categories.isNotEmpty 
                        ? "${worker.categories.first.name} Expert" 
                        : "Skilled Worker",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.orangeWarning, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          worker.rating.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text("•", style: TextStyle(color: AppColors.muted.withOpacity(0.5))),
                        const SizedBox(width: 6),
                        Text("1.2 km away", style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${worker.hourlyRate.toInt()}",
                    style: AppTextStyles.h2.copyWith(color: AppColors.primaryBlue, fontSize: 20),
                  ),
                  Text(
                    "/hr",
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
