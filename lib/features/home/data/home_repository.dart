import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/worker.dart';

class HomeRepository {
  final DioClient _client;

  HomeRepository(this._client);

  Future<List<Category>> getCategories() async {
    final response = await _client.get(ApiConstants.categories);
    return (response.data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Worker>> getWorkers({String? category}) async {
    final Map<String, dynamic> params = {};
    if (category != null) params['category'] = category;
    
    final response = await _client.get(ApiConstants.workers, queryParameters: params);
    return (response.data as List).map((e) => Worker.fromJson(e)).toList();
  }
}
