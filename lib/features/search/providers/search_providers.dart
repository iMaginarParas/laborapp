import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/home_providers.dart';
import '../../../shared/models/worker.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");

enum WorkerFilter { all, availableNow, topRated, lowestPrice }

final workerFilterProvider = StateProvider<WorkerFilter>((ref) => WorkerFilter.all);

final searchWorkersProvider = FutureProvider<List<Worker>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(workerFilterProvider);
  final repository = ref.watch(homeRepositoryProvider);
  
  var workers = await repository.getWorkers();
  
  if (query.isNotEmpty) {
    workers = workers.where((w) => 
      w.name.toLowerCase().contains(query.toLowerCase()) || 
      w.bio.toLowerCase().contains(query.toLowerCase()) ||
      w.categories.any((c) => c.name.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
  
  switch (filter) {
    case WorkerFilter.availableNow:
      workers = workers.where((w) => w.isAvailable).toList();
      break;
    case WorkerFilter.topRated:
      workers.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case WorkerFilter.lowestPrice:
      workers.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      break;
    case WorkerFilter.all:
    default:
      break;
  }
  
  return workers;
});
