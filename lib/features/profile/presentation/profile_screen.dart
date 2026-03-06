import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/shared/models/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) => _buildProfile(context, ref, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 60, color: AppColors.muted),
              const SizedBox(height: 16),
              const Text("Could not load profile"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserProvider),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(user),
          const SizedBox(height: 24),
          _buildMenuSection([
            _MenuItem(Icons.person_outline, "Edit Profile"),
            _MenuItem(Icons.notifications_none, "Notifications"),
            _MenuItem(Icons.payment, "Payments"),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection([
            _MenuItem(Icons.help_outline, "Help Center"),
            _MenuItem(Icons.privacy_tip_outlined, "Privacy Policy"),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection([
            _MenuItem(
              Icons.logout, 
              "Logout", 
              color: Colors.red,
              onTap: () {
                ref.read(authStateProvider.notifier).state = null;
              },
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: const CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, size: 50, color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 14),
                const SizedBox(width: 4),
                Text(user.city ?? "Location not set", style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: items.map((item) => _buildMenuItem(item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      onTap: item.onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (item.color ?? AppColors.primaryBlue).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: item.color ?? AppColors.primaryBlue, size: 20),
      ),
      title: Text(item.title, style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: item.color ?? AppColors.text,
      )),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback? onTap;

  _MenuItem(this.icon, this.title, {this.color, this.onTap});
}
