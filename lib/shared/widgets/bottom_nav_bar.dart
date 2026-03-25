import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool showPostJob;
  final UserRole currentRole;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.currentRole,
    this.showPostJob = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWorker = currentRole == UserRole.work;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, Icons.home, Strings.of(context, 'home')),
              _buildNavItem(context, 1, Icons.search, Icons.search, Strings.of(context, 'search')),
              if (showPostJob) _buildNavItem(context, 2, Icons.post_add, Icons.post_add, "Post Job", postOffset: 1),
              _buildNavItem(context, showPostJob ? 3 : 2, Icons.assignment_outlined, Icons.assignment, isWorker ? Strings.of(context, 'applied') : Strings.of(context, 'bookings')),
              _buildNavItem(context, showPostJob ? 4 : 3, Icons.person_outline, Icons.person, Strings.of(context, 'profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label, {int postOffset = 0}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryColor : AppColors.muted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primaryColor : AppColors.muted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
