import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/storage_service.dart';

/// Handles authenticating users and fetching/updating profile data.
class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  /// Authenticates [login] (email or phone) + [password].
  /// Persists the returned token both in-memory and on disk.
  Future<String> login(String login, String password) async {
    final response = await _client.post(ApiConstants.login, data: {
      'phone_or_email': login,
      'password': password,
    });
    
    final token = response.data['access_token'] as String;
    DioClient.setToken(token);
    await StorageService.setToken(token);
    return token;
  }

  /// Fetches the currently authenticated user's profile.
  Future<User> getMe() async {
    final response = await _client.get(ApiConstants.me);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  /// Registers a new user account.
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

  /// Applies [updates] to the authenticated user's profile and returns
  /// the refreshed [User] object.
  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final response = await _client.put(ApiConstants.me, data: updates);
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
