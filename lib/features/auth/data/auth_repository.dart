import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/storage_service.dart';

/// Handles authenticating users and fetching/updating profile data.
class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  /// Authenticates [email] + [password].
  /// Persists the returned token both in-memory and on disk.
  Future<String> login(String email, String password) async {
    final response = await _client.post(ApiConstants.login, data: {
      'email': email,
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

  /// Authenticates a user with a Google ID token.
  /// Sends the token to the backend for server-side verification.
  /// Returns the access token on success.
  Future<String> loginWithGoogle(String idToken, {String role = 'employer'}) async {
    final response = await _client.post(ApiConstants.googleAuth, data: {
      'id_token': idToken,
      'role': role,
    });

    final token = response.data['access_token'] as String;
    DioClient.setToken(token);
    await StorageService.setToken(token);
    return token;
  }
}
