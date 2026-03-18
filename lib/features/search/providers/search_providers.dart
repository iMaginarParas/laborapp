import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/home_providers.dart';
import '../../../shared/models/worker.dart';
import '../../../shared/models/job.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");

enum SearchFilter { all, availableNow, topRated, lowestPrice, recentlyPosted }

final searchFilterProvider = StateProvider<SearchFilter>((ref) => SearchFilter.all);

final searchWorkersProvider = FutureProvider<List<Worker>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final repository = ref.watch(homeRepositoryProvider);
  
  final workers = await repository.getWorkers(search: query.isEmpty ? null : query);
  
  var list = [...workers];
  
  switch (filter) {
    case SearchFilter.availableNow:
      return list.where((w) => w.isAvailable).toList();
    case SearchFilter.topRated:
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list;
    case SearchFilter.lowestPrice:
      list.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      return list;
    case SearchFilter.all:
    default:
      return list;
  }
});

final searchJobsProvider = FutureProvider<List<Job>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final repository = ref.watch(homeRepositoryProvider);
  
  final jobs = await repository.getJobs(search: query.isEmpty ? null : query);
  
  var list = [...jobs];
  
  switch (filter) {
    case SearchFilter.topRated:
      list.sort((a, b) => b.salaryMax.compareTo(a.salaryMax));
      return list;
    case SearchFilter.recentlyPosted:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    case SearchFilter.all:
    default:
      return list;
  }
});
