import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    String url = dotenv.get('API_BASE_URL', fallback: 'https://laborgrow-production.up.railway.app/api/v1');
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
}
