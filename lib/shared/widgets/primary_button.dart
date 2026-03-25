import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';

class PrimaryButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the user's role: UserRole.hire vs UserRole.work
    final role = ref.watch(currentRoleProvider);
    final isWorker = role == UserRole.work;
    
    // Choose the primary color dynamically based on role
    final primaryColor = isWorker ? AppColors.successGreen : AppColors.primaryColor;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.white : primaryColor,
        foregroundColor: isSecondary ? primaryColor : AppColors.white,
        side: isSecondary ? BorderSide(color: primaryColor) : null,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isSecondary ? primaryColor : AppColors.white,
              ),
            )
          : Text(text),
    );
  }
}
