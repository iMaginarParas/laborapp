import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/widgets/category_chip.dart';
import 'package:flutter_app/shared/widgets/worker_card.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/features/worker_profile/presentation/worker_profile_screen.dart';
import 'package:flutter_app/features/search/presentation/search_screen.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/shared/models/worker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedLanguage = "English";
  final List<String> _languages = ["English", "हिन्दी", "मराठी", "தமிழ்", "తెలుగు", "বাংলা"];

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final workersAsync = ref.watch(workersProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(workersProvider);
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
              _buildSectionHeader("Services", "See all →"),
              const SizedBox(height: 12),
              _buildCategories(ref, categoriesAsync, selectedCategory),
              const SizedBox(height: 24),
              _buildNearbyHeader("Nearby Workers", "12 online", "Map →"),
              const SizedBox(height: 16),
              _buildWorkersList(workersAsync),
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
                  ref.watch(currentUserProvider).when(
                    data: (user) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Good morning",
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Text("👋", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.name,
                          style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              user.city ?? "Sector 18, Noida",
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(height: 50, width: 100),
                    error: (_, __) => Text("Welcome", style: AppTextStyles.h2.copyWith(color: AppColors.white)),
                  ),
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
                                "Search painter, cleaner...",
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
                                  Text("Noida", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
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
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
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
          const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Noida, Uttar Pradesh",
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "Showing workers within 10 km",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            "Change →",
            style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguage == lang;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLanguage = lang),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  lang,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
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
          Text(
            link,
            style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primaryBlue),
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
      onTap: () => ref.read(currentRoleProvider.notifier).state = role,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.primaryBlue : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
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
          Text(
            linkText,
            style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(WidgetRef ref, AsyncValue<List<Category>> asyncValue, String? selectedSlug) {
    return SizedBox(
      height: 100,
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
        data: (workers) => ListView.builder(
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
}
