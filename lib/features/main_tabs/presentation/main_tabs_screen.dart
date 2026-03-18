import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/home/presentation/home_screen.dart';
import 'package:flutter_app/features/search/presentation/search_screen.dart';
import 'package:flutter_app/features/booking/presentation/bookings_list_screen.dart';
import 'package:flutter_app/features/jobs/presentation/my_applications_screen.dart';
import 'package:flutter_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter_app/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter_app/features/main_tabs/providers/navigation_providers.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/features/hire/presentation/create_job_screen.dart';

class MainTabsScreen extends ConsumerWidget {
  const MainTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final currentRole = ref.watch(currentRoleProvider);
    
    // Worker can't post a job. Post job is only for Hire role.
    final showPostJob = currentRole == UserRole.hire;

    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      if (showPostJob) const CreateJobScreen(),
      showPostJob ? const BookingsListScreen() : const MyApplicationsScreen(),
      const ProfileScreen(),
    ];

    // Ensure currentIndex doesn't exceed bounds when toggling
    final safeIndex = currentIndex >= screens.length ? screens.length - 1 : currentIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[safeIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: safeIndex,
        currentRole: currentRole,
        showPostJob: showPostJob,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
      ),
    );
  }
}
