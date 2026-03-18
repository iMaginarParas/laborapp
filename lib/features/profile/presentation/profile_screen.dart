import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/shared/models/user.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/features/post_job/presentation/post_job_screen.dart';
import 'package:flutter_app/features/jobs/presentation/my_applications_screen.dart';
import 'package:flutter_app/features/hire/presentation/my_job_posts_screen.dart';
import 'package:flutter_app/features/hire/presentation/create_job_screen.dart';
import 'package:flutter_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:flutter_app/features/profile/presentation/notification_screen.dart';
import 'package:flutter_app/features/profile/providers/notification_providers.dart';

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
    void showWorkingOnIt() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.of(context, 'working_on_it')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(user),
          const SizedBox(height: 24),
          if (ref.watch(currentRoleProvider) == UserRole.work) ...[
             _buildAvailabilityToggle(context, ref, user),
             const SizedBox(height: 16),
          ],
          _buildMenuSection([
            _MenuItem(
              Icons.person_outline, 
              "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                );
              },
            ),
            if (ref.watch(currentRoleProvider) == UserRole.work)
              _MenuItem(
                Icons.work_outline, 
                "Professional Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PostJobScreen()),
                  );
                },
              )
            else
              _MenuItem(
                Icons.add_box_outlined, 
                "Post a Job",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateJobScreen()),
                  );
                },
              ),
            _MenuItem(
              Icons.assignment_outlined, 
              ref.watch(currentRoleProvider) == UserRole.work ? "My Applications" : "My Job Posts", 
              onTap: () {
                if (ref.read(currentRoleProvider) == UserRole.work) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const MyApplicationsScreen())
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const MyJobPostsScreen())
                  );
                }
              }
            ),
            _MenuItem(
              Icons.notifications_none, 
              "Notifications", 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const NotificationScreen()),
                );
              },
              trailing: ref.watch(unreadNotificationsCountProvider) > 0 
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      ref.watch(unreadNotificationsCountProvider).toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            ),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection([
            _MenuItem(Icons.help_outline, "Help Center", onTap: showWorkingOnIt),
            _MenuItem(Icons.privacy_tip_outlined, "Privacy Policy", onTap: showWorkingOnIt),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection([
            _MenuItem(
              Icons.logout, 
              Strings.of(context, 'logout'), 
              color: Colors.red,
              onTap: () async {
                await StorageService.removeToken();
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

  Widget _buildAvailabilityToggle(BuildContext context, WidgetRef ref, User user) {
    // Note: User model might need isAvailable field, but for now we rely on a default or local state
    // Let's assume for now we use a simple local toggle or refetch
    // In a real app, this would be a separate provider or field in User
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: AppColors.successGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Available Now", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text("Visible to employers", style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: user.isAvailable, 
            activeColor: AppColors.primaryBlue,
            onChanged: (val) async {
              try {
                await ref.read(authRepositoryProvider).updateProfile({"is_available": val});
                ref.invalidate(currentUserProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? "You are now available" : "You are now unavailable")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update status")),
                  );
                }
              }
            },
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
      trailing: item.trailing ?? const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
    );
  }
}
class _MenuItem {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;

  _MenuItem(this.icon, this.title, {this.color, this.onTap, this.trailing});
}
