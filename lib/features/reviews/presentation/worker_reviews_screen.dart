import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import '../providers/review_providers.dart';

class WorkerReviewsScreen extends ConsumerWidget {
  final String workerId;
  final String workerName;

  const WorkerReviewsScreen({
    super.key, 
    required this.workerId, 
    required this.workerName
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(workerReviewsProvider(workerId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text("User Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(workerName, style: AppTextStyles.bodySmall),
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
      body: reviewsAsync.when(
        data: (reviews) => reviews.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: reviews.length,
              itemBuilder: (context, index) => _ReviewCard(review: reviews[index]),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rate_review_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text("No reviews yet", style: AppTextStyles.label.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.reviewerName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(
                  Icons.star, 
                  size: 14, 
                  color: i < review.rating ? Colors.orange : AppColors.border
                )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(review.createdAt), 
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, fontSize: 10)
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
