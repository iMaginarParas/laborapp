import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/core/constants/api_constants.dart';

class Review {
  final String id;
  final String reviewerName;
  final double rating;
  final String content;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      reviewerName: json['reviewer_name'] ?? 'Employer',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      content: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

final workerReviewsProvider = FutureProvider.family<List<Review>, String>((ref, workerId) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.get('${ApiConstants.reviews}/worker/$workerId');
  return (response.data['reviews'] as List).map((e) => Review.fromJson(e)).toList();
});
