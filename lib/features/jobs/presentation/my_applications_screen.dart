import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/job_application.dart';
import 'package:flutter_app/shared/widgets/badge_pill.dart';
import '../providers/job_providers.dart';
import '../../chat/presentation/chat_screen.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Strings.of(context, 'my_applications'), style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myApplicationsProvider),
        child: appsAsync.when(
          data: (apps) => apps.isEmpty 
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: apps.length,
                itemBuilder: (context, index) => _ApplicationCard(application: apps[index]),
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error loading applications: $e")),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(Strings.of(context, 'no_applications'), style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(Strings.of(context, 'apply_hint'), style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final JobApplication application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final job = application.job;
    if (job == null) return const SizedBox.shrink();

    Color statusColor;
    switch (application.status.toLowerCase()) {
      case 'accepted':
        statusColor = AppColors.successGreen;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.orangeWarning;
    }

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
              Text(
                job.title,
                style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              BadgePill(
                label: application.status.toUpperCase(),
                color: statusColor,
                backgroundColor: statusColor.withOpacity(0.1),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.chat_outlined, color: AppColors.primaryColor, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => ChatScreen(userName: job.title)), // Use job title or mock employer
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            job.jobCity,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.muted),
              const SizedBox(width: 8),
              Text(
                "${Strings.of(context, 'applied_on')} ${_formatDate(application.createdAt)}",
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
              const Spacer(),
              if (application.status.toLowerCase() == 'pending')
                Text(
                  Strings.of(context, 'withdraw'),
                  style: AppTextStyles.label.copyWith(color: Colors.red, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
