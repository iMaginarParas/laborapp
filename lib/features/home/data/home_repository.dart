import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/worker.dart';
import '../../../shared/models/job.dart';

class HomeRepository {
  final DioClient _client;

  HomeRepository(this._client);

  Future<List<Category>> getCategories() async {
    final response = await _client.get(ApiConstants.categories);
    return (response.data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Worker>> getWorkers({String? category, String? search}) async {
    final Map<String, dynamic> params = {};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    
    final response = await _client.get(ApiConstants.workers, queryParameters: params);
    return (response.data as List).map((e) => Worker.fromJson(e)).toList();
  }

  Future<List<Job>> getJobs({String? category, String? search}) async {
    final Map<String, dynamic> params = {};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    
    final response = await _client.get(ApiConstants.jobs, queryParameters: params);
    return (response.data as List).map((e) => Job.fromJson(e)).toList();
  }
}
