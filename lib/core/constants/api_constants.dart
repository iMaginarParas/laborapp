import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'https://laborgrow-production.up.railway.app/api/v1');

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String workers = '/workers';
  static const String categories = '/categories';
  static const String bookings = '/bookings';
  static const String me = '/auth/me';
}
