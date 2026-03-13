import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response!.data != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            return detail;
          } else if (detail is List && detail.isNotEmpty) {
            // Handle Pydantic validation error format
            final firstError = detail.first;
            if (firstError is Map && firstError.containsKey('msg')) {
              return firstError['msg'].toString();
            }
            return detail.toString();
          }
          return detail.toString();
        }
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timed out. Please check your internet.";
        case DioExceptionType.sendTimeout:
          return "Request timed out. Please try again.";
        case DioExceptionType.receiveTimeout:
          return "Server is taking too long to respond.";
        case DioExceptionType.badResponse:
          return "Server error: ${error.response?.statusCode}";
        case DioExceptionType.cancel:
          return "Request was cancelled.";
        case DioExceptionType.connectionError:
          return "No internet connection.";
        default:
          return "Something went wrong. Please try again.";
      }
    }
    return error.toString();
  }
}
