import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/job_application.dart';
import 'package:flutter_app/features/jobs/providers/job_providers.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/core/constants/api_constants.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';

class JobApplicantsScreen extends ConsumerWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsScreen({
    super.key, 
    required this.jobId, 
    required this.jobTitle
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(jobApplicantsProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text("Applicants", style: AppTextStyles.h3),
            Text(jobTitle, style: AppTextStyles.bodySmall),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(jobApplicantsProvider(jobId)),
        child: appsAsync.when(
          data: (apps) => apps.isEmpty 
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: apps.length,
                itemBuilder: (context, index) => _ApplicantCard(application: apps[index]),
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.border),
          SizedBox(height: 16),
          Text("No applicants yet", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _ApplicantCard extends ConsumerStatefulWidget {
  final JobApplication application;
  const _ApplicantCard({required this.application});

  @override
  ConsumerState<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends ConsumerState<_ApplicantCard> {
  bool _isProcessing = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);
    try {
      final client = ref.read(dioClientProvider);
      await client.patch(
        '${ApiConstants.applications}/${widget.application.id}/status', 
        data: {'status': status}
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Application $status")),
        );
        ref.invalidate(jobApplicantsProvider(widget.application.jobId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update application status")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.application.worker;
    if (worker == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleBlue,
                child: Text(worker.categories.first.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    Text("${worker.experienceYears}+ years exp.", style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 2),
                      Text(worker.rating.toString(), style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text("Rating", style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.application.status.toLowerCase() == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => _updateStatus('rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: "Hire Worker", 
                    isLoading: _isProcessing,
                    onPressed: () => _updateStatus('accepted'),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.application.status == 'accepted' ? AppColors.greenBG : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.application.status.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: widget.application.status == 'accepted' ? AppColors.successGreen : AppColors.muted,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
        ],
      ),
    );
  }
}
