import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class BadgePill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color backgroundColor;

  BadgePill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor = AppColors.paleBlue,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: activeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: activeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
