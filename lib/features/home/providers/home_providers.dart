import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/home/data/home_repository.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/shared/models/worker.dart';

final dioClientProvider = Provider((ref) => DioClient());

final homeRepositoryProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return HomeRepository(client);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(homeRepositoryProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final workersProvider = FutureProvider<List<Worker>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return ref.watch(homeRepositoryProvider).getWorkers(category: selectedCategory);
});

final jobsProvider = FutureProvider<List<Job>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return ref.watch(homeRepositoryProvider).getJobs(category: selectedCategory);
});

final jobFilterProvider = StateProvider<String>((ref) => "All Jobs");

final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final jobsAsync = ref.watch(jobsProvider);
  final filter = ref.watch(jobFilterProvider);
  final user = ref.watch(currentUserProvider).maybeWhen(data: (u) => u, orElse: () => null);

  return jobsAsync.whenData((jobs) {
    if (filter == "All Jobs") return jobs;
    if (filter == "Nearby (2km)") {
      // Logic: mock lat/lng check or if dist < 2
      // For now, let's just return jobs with lat/lng > 0 or first 3
      return jobs.take(3).toList();
    }
    if (filter == "Same City") {
      if (user?.city == null) return jobs;
      return jobs.where((j) => j.jobCity.toLowerCase() == user!.city!.toLowerCase()).toList();
    }
    if (filter == "High Pay") {
      return jobs.where((j) => j.salaryMin >= 1000).toList();
    }
    return jobs;
  });
});
