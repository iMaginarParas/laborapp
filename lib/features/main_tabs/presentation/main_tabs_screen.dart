import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/home/presentation/home_screen.dart';
import 'package:flutter_app/features/search/presentation/search_screen.dart';
import 'package:flutter_app/features/booking/presentation/bookings_list_screen.dart';
import 'package:flutter_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter_app/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter_app/features/main_tabs/providers/navigation_providers.dart';

class MainTabsScreen extends ConsumerWidget {
  const MainTabsScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookingsListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
      ),
    );
  }
}
