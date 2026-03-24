import 'package:dio/dio.dart';


/// Translates [DioException]s and raw errors into user-friendly messages.
class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      // 1. Try to extract a server-provided detail message first
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map) {
          if (data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is String) return detail;
            if (detail is List && detail.isNotEmpty) {
              // Pydantic validation error format
              final first = detail.first;
              if (first is Map && first.containsKey('msg')) {
                return first['msg'].toString();
              }
              return detail.toString();
            }
            return detail.toString();
          }
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
        }
      }

      // 2. Map status codes → friendly messages
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return _statusCodeMessage(statusCode);
      }

      // 3. Map timeout / connectivity errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please check your internet.';
        case DioExceptionType.sendTimeout:
          return 'Request timed out. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Server is taking too long to respond.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.connectionError:
          String msg = 'Unable to connect to the server. Please check your internet.';
          if (error.requestOptions.baseUrl.isNotEmpty) {
            msg += '\n(Target: ${error.requestOptions.baseUrl}${error.requestOptions.path})';
          }
          return msg;
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return error.toString();
  }

  static String _statusCodeMessage(int code) {
    switch (code) {
      case 400: return 'Invalid request. Please check your input.';
      case 401: return 'Your session has expired. Please log in again.';
      case 403: return 'You do not have permission to perform this action.';
      case 404: return 'The requested resource was not found.';
      case 408: return 'Request timed out. Please try again.';
      case 429: return 'Too many requests. Please wait a moment and retry.';
      case 500: return 'Server error. Our team has been notified.';
      case 503: return 'Service is temporarily unavailable. Try again later.';
      default:  return 'Server error ($code). Please try again.';
    }
  }
}
