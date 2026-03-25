import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/features/jobs/providers/job_providers.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'create_job_screen.dart';
import 'job_applicants_screen.dart';

class MyJobPostsScreen extends ConsumerWidget {
  const MyJobPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(myPostedJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("My Job Posts", style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myPostedJobsProvider),
        child: jobsAsync.when(
          data: (jobs) => jobs.isEmpty 
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: jobs.length,
                itemBuilder: (context, index) => _JobPostCard(job: jobs[index]),
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateJobScreen())),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.post_add, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text("No jobs posted yet", style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text("Post your first job classified to find workers", 
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            PrimaryButton(
              text: "Post a Job", 
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateJobScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobPostCard extends StatelessWidget {
  final Job job;
  const _JobPostCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job.title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.status.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(job.jobCity, style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: AppColors.muted),
              const SizedBox(width: 8),
              Text("0 Applicants", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => JobApplicantsScreen(jobId: job.id, jobTitle: job.title),
                    ),
                  );
                },
                child: Text("Manage →", style: AppTextStyles.label.copyWith(color: AppColors.primaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
