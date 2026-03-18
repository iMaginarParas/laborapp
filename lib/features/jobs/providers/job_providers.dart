import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/shared/models/job_application.dart';
import 'package:flutter_app/core/constants/api_constants.dart';

final myApplicationsProvider = FutureProvider<List<JobApplication>>((ref) async {
  try {
    final client = ref.watch(dioClientProvider);
    final response = await client.get('${ApiConstants.applications}/my-applications');
    if (response.data is List) {
      return (response.data as List).map((e) => JobApplication.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    debugPrint("Error loading applications: $e");
    return [];
  }
});

final myPostedJobsProvider = FutureProvider<List<Job>>((ref) async {
  try {
    final client = ref.watch(dioClientProvider);
    final response = await client.get('${ApiConstants.jobs}/my-posts');
    if (response.data is List) {
      return (response.data as List).map((e) => Job.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    debugPrint("Error loading my posted jobs: $e");
    return [];
  }
});

final jobApplicantsProvider = FutureProvider.family<List<JobApplication>, String>((ref, jobId) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.get(ApiConstants.applications + '/job/$jobId');
  return (response.data as List).map((e) => JobApplication.fromJson(e)).toList();
});
