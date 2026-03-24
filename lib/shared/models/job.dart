import 'worker.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String jobCity;
  final double salaryMin;
  final double salaryMax;
  final int openings;
  final String status;
  final DateTime createdAt;
  final String? employerId;
  final Category? category;
  final double? lat;
  final double? lng;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.jobCity,
    required this.salaryMin,
    required this.salaryMax,
    required this.openings,
    required this.status,
    required this.createdAt,
    this.employerId,
    this.category,
    this.lat,
    this.lng,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      jobCity: json['job_city'] ?? '',
      salaryMin: (json['salary_min'] as num?)?.toDouble() ?? 0.0,
      salaryMax: (json['salary_max'] as num?)?.toDouble() ?? 0.0,
      openings: json['openings'] ?? 1,
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(json['created_at']),
      employerId: json['employer_id']?.toString(),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
