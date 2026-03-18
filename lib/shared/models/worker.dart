import 'package:flutter/foundation.dart';

class Category {
  final int id;
  final String name;
  final String emoji;
  final String slug;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'General',
      emoji: json['emoji'] ?? '💼',
      slug: json['slug'] ?? 'general',
    );
  }
}

class WorkerSkill {
  final String skillName;

  WorkerSkill({required this.skillName});

  factory WorkerSkill.fromJson(Map<String, dynamic> json) {
    return WorkerSkill(skillName: json['skill_name']);
  }
}

class Worker {
  final String id;
  final String name;
  final String? profilePicUrl;
  final String bio;
  final String city;
  final double hourlyRate;
  final int experienceYears;
  final double rating;
  final bool isVerified;
  final bool isAvailable;
  final int minHours;
  final List<Category> categories;
  final List<WorkerSkill> skills;

  Worker({
    required this.id,
    required this.name,
    this.profilePicUrl,
    required this.bio,
    required this.city,
    required this.hourlyRate,
    required this.experienceYears,
    required this.rating,
    required this.isVerified,
    required this.isAvailable,
    required this.minHours,
    required this.categories,
    required this.skills,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};
    return Worker(
      id: json['id'].toString(),
      name: userData['name'] ?? 'Worker',
      profilePicUrl: userData['profile_pic_url'],
      bio: json['bio'] ?? "",
      city: json['city'] ?? "",
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      experienceYears: json['experience_years'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] ?? false,
      isAvailable: json['is_available'] ?? true,
      minHours: json['min_hours'] ?? 1,
      categories: (json['categories'] is List)
          ? (json['categories'] as List).map((c) => Category.fromJson(c)).toList()
          : [],
      skills: (json['skills'] as List?)
          ?.map((s) => WorkerSkill.fromJson(s))
          .toList() ?? [],
    );
  }
}
