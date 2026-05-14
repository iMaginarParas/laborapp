import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_text_styles.dart';

class SnackBarUtils {
  static void showError(BuildContext context, String message) {
    _show(context, message, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void _show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.white,
              size: 20,
            ),
            AppLayout.width12,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radius12),
        ),
        margin: const EdgeInsets.all(AppLayout.space16),
        elevation: 4,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
