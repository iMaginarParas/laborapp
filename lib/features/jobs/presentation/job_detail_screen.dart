import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/core/constants/api_constants.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isApplying = false;

  Future<void> _handleApply() async {
    setState(() => _isApplying = true);
    try {
      // Using existing updateProfile to simulate application
      // For now, let's assume we call the /applications endpoint via raw dio if repo doesn't have it
      final client = ref.read(dioClientProvider);
      await client.post(ApiConstants.applications, data: {'job_id': widget.job.id});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to apply. You might have already applied.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final currentRole = ref.watch(currentRoleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Job Details", style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.job.category?.emoji ?? "💼",
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.job.title, style: AppTextStyles.h2.copyWith(fontSize: 20)),
                      Text(widget.job.jobCity, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoCard(),
            const SizedBox(height: 32),
            Text("Description", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Text(
              widget.job.description,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, height: 1.5),
            ),
            const SizedBox(height: 12),
            // Show message if it's the user's own job
            userAsync.maybeWhen(
              data: (user) {
                if (widget.job.employerId != null && user.id == widget.job.employerId) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("This is your own job posting.")),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
              orElse: () => const SizedBox(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: userAsync.when(
        data: (user) {
          final isOwner = widget.job.employerId != null && user.id == widget.job.employerId;
          final isWorker = currentRole == UserRole.work;

          if (isWorker && !isOwner) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: PrimaryButton(
                  text: "Apply for this Job",
                  isLoading: _isApplying,
                  onPressed: _handleApply,
                ),
              ),
            );
          }
          return const SizedBox(height: 1);
        },
        loading: () => const SizedBox(height: 1),
        error: (_, __) => const SizedBox(height: 1),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paleBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.payments_outlined, "Salary", "₹${widget.job.salaryMin.toInt()}"),
          _buildInfoItem(Icons.people_outline, "Openings", "${widget.job.openings}"),
          _buildInfoItem(Icons.location_on_outlined, "Type", "Full-time"),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, fontSize: 10)),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      ],
    );
  }
}
