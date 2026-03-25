import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_layout.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/widgets/category_chip.dart';
import 'package:flutter_app/shared/widgets/worker_card.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/features/worker_profile/presentation/worker_profile_screen.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/widgets/job_card.dart';
import 'package:flutter_app/features/home/presentation/role_selection_screen.dart';
import 'package:flutter_app/features/jobs/presentation/job_detail_screen.dart';
import 'package:flutter_app/features/home/presentation/language_selection_screen.dart';
import 'package:flutter_app/core/services/location_service.dart';
import 'package:flutter_app/features/main_tabs/providers/navigation_providers.dart';
import 'package:flutter_app/features/chat/presentation/chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> _languages = ["English", "हिन्दी"];

  void _showWorkingOnIt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Strings.of(context, 'working_on_it')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final workersAsync = ref.watch(workersProvider);
    final jobsAsync = ref.watch(jobsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final currentRole = ref.watch(currentRoleProvider);
    final isWorker = currentRole == UserRole.work;

    return Scaffold(
      backgroundColor: Colors.white,
      body: currentRole == UserRole.work ? _buildWorkerHome(context, ref) : _buildHireHome(context, ref),
    );
  }

  Widget _buildHireHome(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final workersAsync = ref.watch(workersProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoriesProvider);
        ref.invalidate(workersProvider);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, isWorker: false),
            AppLayout.height20,
            _buildLocationCard(),
            AppLayout.height16,
            _buildLanguageSelector(),
            AppLayout.height24,
            _buildSectionHeader(
              Strings.of(context, 'services'), 
              "${Strings.of(context, 'see_all')} →",
              onTap: _showWorkingOnIt,
            ),
            AppLayout.height8,
            _buildCategories(ref, categoriesAsync, selectedCategory),
            AppLayout.height16,
            _buildNearbyHeader(
              Strings.of(context, 'nearby_workers'), 
              "12 online", 
              "Map →",
              onTap: () => ref.read(navigationIndexProvider.notifier).state = 1, // Search Tab
            ),
            AppLayout.height16,
            _buildWorkersList(workersAsync),
            _buildSectionHeader("Post a Job", ""),
            _buildPostJobBanner(context, ref),
            AppLayout.height48,
          ],
        ),
      ),
    );
  }

  Widget _buildPostJobBanner(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(AppLayout.space24),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C5F8A), Color(0xFF3D7AB5)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Circles
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Reach 10,000+ workers",
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Post your job &\nhire the best talent",
                  style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 20, height: 1.2),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Post Job Tab or Screen
                    ref.read(navigationIndexProvider.notifier).state = 2;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Post Job", style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w900, color: AppColors.primaryColor)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerHome(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(filteredJobsProvider);
    final user = ref.watch(currentUserProvider).value;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(jobsProvider);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWorkerHeader(context, ref, user),
            _buildMapSection(context, jobsAsync),
            _buildFilterChips(context, ref),
            _buildLanguageSelector(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Jobs Near You", style: AppTextStyles.h3),
                  jobsAsync.maybeWhen(
                    data: (jobs) => Text("${jobs.length} available", 
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.successGreen, fontWeight: FontWeight.bold)
                    ),
                    orElse: () => const SizedBox(),
                  ),
                ],
              ),
            ),
            _buildWorkerJobsList(jobsAsync),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerHeader(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B5E20), // Dark green as per image
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Worker Mode 👷", style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(user?.name ?? "AJAY PAWAR", style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 22)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                          const SizedBox(width: 4),
                          Text("${user?.city ?? "Noida"}, UP", style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                  _buildRoleToggle(ref),
                ],
              ),
              const SizedBox(height: 24),
              // Worker Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF1B5E20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
                              child: Container(
                                color: Colors.transparent,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Search jobs near you...",
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 4),
                                Text("10 km", style: AppTextStyles.label.copyWith(color: Colors.black87, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      ref.read(navigationIndexProvider.notifier).state = 1; // Redirect to Search
                    },
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.mic_none, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, AsyncValue<List<Job>> jobsAsync) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1544984243-ea577c1d1d2b?q=80&w=1000&auto=format&fit=crop"),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // Dynamic Map Pins from Jobs
          jobsAsync.maybeWhen(
            data: (jobs) => Stack(
              children: jobs.asMap().entries.map((entry) {
                final i = entry.key;
                final job = entry.value;
                // Simulating random positions around center based on index
                final top = 60.0 + (i % 4) * 40.0;
                final left = (i % 2 == 0) ? 40.0 + (i * 20) : null;
                final right = (i % 2 != 0) ? 40.0 + (i * 15) : null;

                return _buildMapPin(
                  context: context,
                  job: job,
                  top: top,
                  left: left,
                  right: right,
                );
              }).toList(),
            ),
            orElse: () => const SizedBox(),
          ),
          // User Center Point
          Center(
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: CircleAvatar(radius: 6, backgroundColor: AppColors.primaryColor),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                final current = ref.read(jobFilterProvider);
                if (current == "Nearby (2km)") {
                  ref.read(jobFilterProvider.notifier).state = "All Jobs";
                } else {
                  ref.read(jobFilterProvider.notifier).state = "Nearby (2km)";
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      ref.watch(jobFilterProvider) == "Nearby (2km)" ? "2 km range" : "10 km range",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin({
    required BuildContext context,
    required Job job,
    required double top,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => JobDetailScreen(job: job))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Text(job.category?.emoji ?? "💼", style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                "${job.title.split(' ').first} ₹${job.salaryMin.toInt()}",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(jobFilterProvider);
    final filters = ["All Jobs", "Nearby (2km)", "Same City", "High Pay", "Today"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: filters.map((f) {
          final isSelected = f == currentFilter;
          return GestureDetector(
            onTap: () => ref.read(jobFilterProvider.notifier).state = f,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
              child: Text(f, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkerJobsList(AsyncValue<List<Job>> jobsAsync) {
    return jobsAsync.when(
      data: (jobs) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: jobs.length,
        itemBuilder: (context, index) => _buildWorkerJobCard(context, jobs[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildWorkerJobCard(BuildContext context, Job job) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => JobDetailScreen(job: job))),
      child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(job.category?.emoji ?? "💼", style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: AppTextStyles.h3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text("Vikash Mehta", style: TextStyle(color: Colors.grey, fontSize: 13)), // Mocked client name
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.orange, size: 12),
                          const Icon(Icons.star, color: Colors.orange, size: 12),
                          const Icon(Icons.star, color: Colors.orange, size: 12),
                          const Icon(Icons.star, color: Colors.orange, size: 12),
                          const Icon(Icons.star, color: Colors.orange, size: 12),
                          const SizedBox(width: 4),
                          const Text("Client", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMiniTag(context, Icons.location_on, "1.8 km", Colors.redAccent),
                          const SizedBox(width: 8),
                          _buildMiniTag(context, Icons.access_time_filled, "Tomorrow 10 AM", Colors.orange),
                          const SizedBox(width: 8),
                          _buildMiniTag(context, Icons.payments, "₹${job.salaryMin.toInt()}", Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => JobDetailScreen(job: job))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B5E20),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text("Apply", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChatScreen(userName: "Vikash Mehta"))),
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
                      border: Border(left: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Color(0xFF94A3B8), size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMiniTag(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, {bool isWorker = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppLayout.space32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppLayout.space24, AppLayout.space8, AppLayout.space24, AppLayout.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Role Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
                    onPressed: _showWorkingOnIt,
                  ),
                  Expanded(
                    child: ref.watch(currentUserProvider).when(
                      data: (user) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Good morning", // Simplified for clean look
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text("👋", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.name.toUpperCase(),
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                              fontSize: 18, // Reduced from 24
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white.withOpacity(0.7), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                (user.city ?? "Noida").toUpperCase(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(height: 50, width: 100),
                      error: (_, _) => Text("WELCOME", style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 18)),
                    ),
                  ),
                  AppLayout.width16,
                  _buildRoleToggle(ref),
                ],
              ),
              AppLayout.height16,
              
              // Search Bar Group
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Switch to Search Tab
                        ref.read(navigationIndexProvider.notifier).state = 1;
                      },
                      child: Container(
                        height: 54, // Consistent touch target
                        padding: EdgeInsets.symmetric(horizontal: AppLayout.space16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppLayout.borderRadius16,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.muted, size: 22),
                            AppLayout.width12,
                            Expanded(
                                child: Text(
                                  Strings.of(context, 'search_placeholder'),
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted.withOpacity(0.7), fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                                  const SizedBox(width: 4),
                                  ref.watch(currentUserProvider).maybeWhen(
                                    data: (user) => Text(
                                      (user.city ?? "Noida").toUpperCase(), 
                                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 12)
                                    ),
                                    orElse: () => Text("Noida", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppLayout.width12,
                  // Voice Input Pill
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C9BD8),
                      borderRadius: AppLayout.borderRadius16,
                    ),
                    child: InkWell(
                      onTap: () {
                        // Switch to Search Tab and trigger voice if possible
                        // For now just switch tab
                        ref.read(navigationIndexProvider.notifier).state = 1;
                      },
                      borderRadius: AppLayout.borderRadius16,
                      child: const Icon(Icons.mic, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLocationPicker() async {
    String selectedRadius = "2 km";
    String? selectedCity;
    final controller = TextEditingController(text: "Noida, Uttar Pradesh");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Set Your Location",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Georgia', color: AppColors.text),
              ),
              const SizedBox(height: 2),
              const Text(
                "Find workers or jobs near you",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // GPS Button
              GestureDetector(
                onTap: () async {
                  try {
                    final service = LocationService();
                    final pos = await service.getCurrentPosition();
                    if (pos != null) {
                      final placemarks = await service.getAddressFromLatLng(pos);
                      setSheetState(() => controller.text = placemarks ?? "Unknown Location");
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.settings_input_antenna, color: AppColors.primaryColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Use My Current Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryColor)),
                          Text("Auto-detect GPS location", style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
                            Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your location",
                    hintStyle: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("SEARCH RADIUS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["2 km", "10 km", "25 km", "Same City"].map((r) {
                    final isSelected = selectedRadius == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedRadius = r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                          ),
                          child: Text(r, style: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Popular Cities
              const Text("POPULAR CITIES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.5,
                children: ["Noida", "Delhi", "Mumbai", "Bangalore"].map((city) {
                  final isSelected = selectedCity == city;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedCity = city),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: isSelected ? Colors.white : Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Text(city, style: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final cityToUse = selectedCity ?? controller.text.split(',').first;
                    Navigator.pop(context);
                    await ref.read(authRepositoryProvider).updateProfile({"city": cityToUse});
                    ref.invalidate(currentUserProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location set to $cityToUse")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Apply Location ✓", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final currentRole = ref.watch(currentRoleProvider);
    final isWorker = currentRole == UserRole.work;
    return GestureDetector(
      onTap: _showLocationPicker,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
        padding: AppLayout.screenPaddingAll,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppLayout.borderRadius16,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.my_location, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ref.watch(currentUserProvider).maybeWhen(
                    data: (user) => Text(
                      (user.city ?? "Noida").toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                    orElse: () => Text(
                      "NOIDA",
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isWorker ? "Showing all jobs posted" : "Showing all available workers", 
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              "CHANGE →",
              style: AppTextStyles.label.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final locale = ref.watch(localeProvider);
    final currentLang = locale.languageCode == 'hi' ? 'हिन्दी' : 'English';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const LanguageSelectionScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.language, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "App Language: $currentLang",
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Text(
                "SELECT →",
                style: AppTextStyles.label.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyHeader(String title, String badge, String link, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          AppLayout.width12,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.space8, vertical: AppLayout.space4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap ?? _showWorkingOnIt,
            child: Text(
              link,
              style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleToggle(WidgetRef ref) {
    final currentRole = ref.watch(currentRoleProvider);
    final isHire = currentRole == UserRole.hire;

    return Container(
      padding: const EdgeInsets.all(AppLayout.space4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppLayout.radius32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(ref, "Hire", "🏠", isHire, UserRole.hire),
          _toggleButton(ref, "Work", "👷", !isHire, UserRole.work),
        ],
      ),
    );
  }

  Widget _toggleButton(WidgetRef ref, String label, String emoji, bool isActive, UserRole role) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const RoleSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.space12, vertical: AppLayout.space8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radius24),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            AppLayout.width4,
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.primaryColor : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String linkText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          GestureDetector(
            onTap: onTap ?? _showWorkingOnIt,
            child: Text(
              linkText,
              style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(WidgetRef ref, AsyncValue<List<Category>> asyncValue, String? selectedSlug) {
    return SizedBox(
      height: 115,
      child: asyncValue.when(
        data: (categories) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: AppLayout.space24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryChip(
              label: category.name,
              emoji: category.emoji,
              isSelected: selectedSlug == category.slug,
              onTap: () {
                if (selectedSlug == category.slug) {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                } else {
                  ref.read(selectedCategoryProvider.notifier).state = category.slug;
                }
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text("Error loading categories")),
      ),
    );
  }

  Widget _buildWorkersList(AsyncValue<List<Worker>> asyncValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
      child: asyncValue.when(
        data: (workers) => workers.isEmpty 
          ? _buildEmptyState("No workers found")
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length > 2 ? 2 : workers.length, // Show only top 2
              itemBuilder: (context, index) => WorkerCard(
                worker: workers[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfileScreen(worker: workers[index]),
                    ),
                  );
                },
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildJobsList(AsyncValue<List<Job>> asyncValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
      child: asyncValue.when(
        data: (jobs) => jobs.isEmpty 
          ? _buildEmptyState("No jobs found")
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobs.length,
              itemBuilder: (context, index) => JobCard(
                job: jobs[index],
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (c) => JobDetailScreen(job: jobs[index]))
                  );
                },
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppLayout.space40),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.border),
            AppLayout.height16,
            Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
