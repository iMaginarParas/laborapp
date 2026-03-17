import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/widgets/category_chip.dart';
import 'package:flutter_app/shared/widgets/worker_card.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/features/worker_profile/presentation/worker_profile_screen.dart';
import 'package:flutter_app/features/search/presentation/search_screen.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/widgets/job_card.dart';
import 'package:flutter_app/features/home/presentation/role_selection_screen.dart';
import 'package:flutter_app/features/jobs/presentation/job_detail_screen.dart';

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
        backgroundColor: AppColors.primaryBlue,
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(workersProvider);
          ref.invalidate(jobsProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 20),
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildLanguageSelector(),
              const SizedBox(height: 24),
              _buildSectionHeader(Strings.of(context, 'services'), Strings.of(context, 'see_all') + " →"),
              const SizedBox(height: 12),
              _buildCategories(ref, categoriesAsync, selectedCategory),
              const SizedBox(height: 24),
              _buildNearbyHeader(
                isWorker ? "Latest Jobs" : Strings.of(context, 'nearby_workers'), 
                isWorker ? "New" : "12 online", 
                "See all →"
              ),
              const SizedBox(height: 16),
              isWorker ? _buildJobsList(jobsAsync) : _buildWorkersList(workersAsync),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Role Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      error: (_, __) => Text("WELCOME", style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildRoleToggle(ref),
                ],
              ),
              const SizedBox(height: 24),
              
              // Search Bar Group
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchScreen())),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.muted, size: 22),
                            const SizedBox(width: 10),
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
                  const SizedBox(width: 12),
                  // Voice Input Pill
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C9BD8), // Lighter blue for the mic pill
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: _showWorkingOnIt,
                      borderRadius: BorderRadius.circular(16),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Location", style: AppTextStyles.h2),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.primaryBlue),
              title: const Text("Use my current location"),
              subtitle: const Text("Precise location using GPS"),
              onTap: () async {
                Navigator.pop(context);
                try {
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fetching current location...")),
                  );
                  // We would call LocationService here
                  // For now, let's simulate updating the profile with a dummy city
                  // or just show a message.
                  // Real implementation would be:
                  // final pos = await LocationService().getCurrentPosition();
                  // final addr = await LocationService().getAddressFromLatLng(pos!);
                  ref.read(authRepositoryProvider).updateProfile({"city": "Noida (Current)"});
                  ref.invalidate(currentUserProvider);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_location, color: AppColors.primaryBlue),
              title: const Text("Enter location manually"),
              onTap: () {
                Navigator.pop(context);
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Enter City"),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: "e.g. Mumbai, Pune"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            ref.read(authRepositoryProvider).updateProfile({"city": controller.text});
                            ref.invalidate(currentUserProvider);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: _showLocationPicker,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            const Icon(Icons.my_location, color: AppColors.primaryBlue, size: 24),
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
              style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _languages.map((lang) {
          final isSelected = ref.watch(localeProvider).languageCode == (lang == 'हिन्दी' ? 'hi' : 'en');
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                final newLocale = Locale(lang == 'हिन्दी' ? 'hi' : 'en');
                ref.read(localeProvider.notifier).state = newLocale;
                StorageService.setLanguage(lang);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  lang,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? AppColors.primaryBlue : AppColors.muted,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNearbyHeader(String title, String badge, String link) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            onTap: _showWorkingOnIt,
            child: Text(
              link,
              style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primaryBlue),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.primaryBlue : Colors.white,
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

  Widget _buildSectionHeader(String title, String linkText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          GestureDetector(
            onTap: _showWorkingOnIt,
            child: Text(
              linkText,
              style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(WidgetRef ref, AsyncValue<List<Category>> asyncValue, String? selectedSlug) {
    return SizedBox(
      height: 115, // Increased height to fix 1px overflow
      child: asyncValue.when(
        data: (categories) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: asyncValue.when(
        data: (workers) => workers.isEmpty 
          ? _buildEmptyState("No workers found")
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.border),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
