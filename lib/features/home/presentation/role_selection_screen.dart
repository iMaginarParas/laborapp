import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Laborgro",
                      style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5),
                    ),
                    ref.watch(currentUserProvider).when(
                          data: (user) => Text(
                            user.name,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, _) => const SizedBox(),
                        ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "How do you want\nto use Laborgro?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32, 
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "You can switch roles anytime from your home\nscreen. One account, both worlds.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                _buildRoleCard(
                  context,
                  ref,
                  role: UserRole.hire,
                  title: "I want to Hire",
                  description:
                      "Post jobs, book workers instantly, pay securely and get work done.",
                  icon: "🏠",
                  features: ["Post Jobs", "Book Instantly", "Track Worker", "Chat & Call"],
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 20),
                _buildRoleCard(
                  context,
                  ref,
                  role: UserRole.work,
                  title: "I want to Work",
                  description:
                      "Find nearby jobs, accept bookings, chat with clients, track your earnings.",
                  icon: "👷",
                  features: ["Find Nearby Jobs", "Track Earnings", "Chat & Call"],
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sync, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      "Switch roles anytime using the toggle on your home screen",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade500, 
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    WidgetRef ref, {
    required UserRole role,
    required String title,
    required String description,
    required String icon,
    required List<String> features,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(currentRoleProvider.notifier).state = role;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(
                color: color, 
                fontSize: 24, 
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.black.withOpacity(0.5), 
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          f,
                          style: AppTextStyles.label.copyWith(
                            color: color, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
