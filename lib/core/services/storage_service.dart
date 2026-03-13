import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  static String? getToken() {
    return _prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    await _prefs.remove('auth_token');
  }

  static Future<void> setLanguage(String lang) async {
    await _prefs.setString('language', lang);
  }

  static String getLanguage() {
    return _prefs.getString('language') ?? 'English';
  }
}
