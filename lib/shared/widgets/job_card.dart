import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/job.dart';

class JobCard extends ConsumerWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final currentRole = ref.watch(currentRoleProvider);

    final showApplyNow = userAsync.maybeWhen(
      data: (user) => currentRole == UserRole.work && user.id != job.employerId,
      orElse: () => false,
    );

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      job.category?.emoji ?? "💼",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          job.jobCity,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${job.salaryMin.toInt()} - ₹${job.salaryMax.toInt()}",
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.text, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTag(Icons.people_outline, "${job.openings} Openings"),
                  const SizedBox(width: 12),
                  _buildTag(Icons.access_time, "Posted recently"),
                  const Spacer(),
                   Text(
                    showApplyNow ? "Apply Now →" : "View Details →",
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
