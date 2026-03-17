import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/home/data/home_repository.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/models/job.dart';

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
