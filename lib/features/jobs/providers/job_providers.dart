import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/shared/models/job_application.dart';
import 'package:flutter_app/core/constants/api_constants.dart';

final myApplicationsProvider = FutureProvider<List<JobApplication>>((ref) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.get(ApiConstants.applications + '/my-applications');
  return (response.data as List).map((e) => JobApplication.fromJson(e)).toList();
});

final myPostedJobsProvider = FutureProvider<List<Job>>((ref) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.get(ApiConstants.jobs + '/my-posts');
  return (response.data as List).map((e) => Job.fromJson(e)).toList();
});

final jobApplicantsProvider = FutureProvider.family<List<JobApplication>, String>((ref, jobId) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.get(ApiConstants.applications + '/job/$jobId');
  return (response.data as List).map((e) => JobApplication.fromJson(e)).toList();
});
