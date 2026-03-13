import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/storage_service.dart';

class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  Future<String> login(String login, String password) async {
    final response = await _client.post(ApiConstants.login, data: {
      'phone_or_email': login,
      'password': password,
    });
    
    final token = response.data['access_token'];
    DioClient.setToken(token);
    await StorageService.setToken(token);
    return token;
  }

  Future<User> getMe() async {
    final response = await _client.get(ApiConstants.me);
    return User.fromJson(response.data);
  }
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String password,
    required String role,
  }) async {
    await _client.post(ApiConstants.register, data: {
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'password': password,
      'role': role,
    });
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final response = await _client.put(ApiConstants.me, data: updates);
    return User.fromJson(response.data);
  }
}
