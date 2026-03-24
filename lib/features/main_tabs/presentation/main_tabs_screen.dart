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

class MainTabsScreen extends ConsumerStatefulWidget {
  const MainTabsScreen({super.key});

  @override
  ConsumerState<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends ConsumerState<MainTabsScreen> {
  @override
  void initState() {
    super.initState();
    // Reset navigation when role changes to avoid index mismatch
    // (e.g. index 2 is Applications for worker, but CreateJob for employer)
  }

  @override
  Widget build(BuildContext context) {
    // Watch role and reset index if it changes
    ref.listen(currentRoleProvider, (previous, next) {
      if (previous != null && previous != next) {
        ref.read(navigationIndexProvider.notifier).state = 0;
      }
    });

    final currentIndex = ref.watch(navigationIndexProvider);
    final currentRole = ref.watch(currentRoleProvider);
    final showPostJob = currentRole == UserRole.hire;

    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      if (showPostJob) const CreateJobScreen(),
      showPostJob ? const BookingsListScreen() : const MyApplicationsScreen(),
      const ProfileScreen(),
    ];

    final safeIndex = currentIndex >= screens.length ? 0 : currentIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[safeIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: safeIndex,
        currentRole: currentRole ?? UserRole.hire,
        showPostJob: showPostJob,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
      ),
    );
  }
}
