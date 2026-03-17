import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class ApiConstants {
  static String get baseUrl {
    // We default to localhost for development. Change this back to Railway for production.
    String url = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8000/api/v1');
    
    // Auto-fix for Android Emulator
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost')) url = url.replaceFirst('localhost', '10.0.2.2');
      if (url.contains('127.0.0.1')) url = url.replaceFirst('127.0.0.1', '10.0.2.2');
    }
    
    return url.endsWith('/') ? url : '$url/';
  }

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String workers = 'workers';
  static const String categories = 'categories';
  static const String bookings = 'bookings';
  static const String jobs = 'jobs';
  static const String hieDashboard = 'hire/dashboard';
  static const String workerDashboard = 'worker/dashboard';
  static const String applications = 'applications';
  static const String reviews = 'reviews';
  static const String me = 'auth/me';
  static const String notifications = 'notifications';
}
