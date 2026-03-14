import 'package:flutter/foundation.dart';

/// Structured logger that suppresses output in release builds.
///
/// Usage:
/// ```dart
/// AppLogger.info('Workers loaded', {'count': workers.length});
/// AppLogger.error('Booking failed', error: e, stackTrace: st);
/// ```
class AppLogger {
  static void info(String message, [Map<String, dynamic>? context]) {
    if (kDebugMode) {
      debugPrint('[INFO] $message${_formatContext(context)}');
    }
  }

  static void warning(String message, [Map<String, dynamic>? context]) {
    if (kDebugMode) {
      debugPrint('[WARN] $message${_formatContext(context)}');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${_formatContext(context)}');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
    }
  }

  static String _formatContext(Map<String, dynamic>? ctx) {
    if (ctx == null || ctx.isEmpty) return '';
    return ' | ${ctx.entries.map((e) => '${e.key}=${e.value}').join(', ')}';
  }
}
