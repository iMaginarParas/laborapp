import 'package:shared_preferences/shared_preferences.dart';

/// Private namespace for all SharedPreferences keys.
/// Centralising keys prevents typo-driven bugs across the codebase.
abstract class _StorageKeys {
  static const String authToken = 'auth_token';
  static const String language  = 'language';
}

/// Thin, statically-accessible wrapper around [SharedPreferences].
///
/// Call [StorageService.init] once during application startup before
/// accessing any other method.
class StorageService {
  static late SharedPreferences _prefs;

  /// Must be called before any reads or writes.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Auth Token ────────────────────────────────────────────────────────────

  static Future<void> setToken(String token) =>
      _prefs.setString(_StorageKeys.authToken, token);

  static String? getToken() => _prefs.getString(_StorageKeys.authToken);

  static Future<void> removeToken() => _prefs.remove(_StorageKeys.authToken);

  // ── Language ──────────────────────────────────────────────────────────────

  static Future<void> setLanguage(String lang) =>
      _prefs.setString(_StorageKeys.language, lang);

  static String getLanguage() =>
      _prefs.getString(_StorageKeys.language) ?? 'English';

  // ── Utility ───────────────────────────────────────────────────────────────

  /// Wipes all persisted data (e.g. on logout).
  static Future<void> clearAll() => _prefs.clear();
}
