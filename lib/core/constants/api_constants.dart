import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _ipAddress = '10.227.208.135'; // Fixed IP for physical device
  
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    return 'http://$_ipAddress:8000/api/v1';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String workers = '/workers';
  static const String categories = '/categories';
  static const String bookings = '/bookings';
  static const String me = '/auth/me';
}
