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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: 32),
              _buildPromoBanner(),
              const SizedBox(height: 32),
              _buildSectionHeader("Browse Services", "See all →"),
              const SizedBox(height: 16),
              _buildCategories(ref, categoriesAsync, selectedCategory),
              const SizedBox(height: 24),
              _buildSectionHeader("Top Rated Nearby", "See all →"),
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
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ref.watch(currentUserProvider).when(
                    data: (user) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Good morning",
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                            ),
                            const SizedBox(width: 4),
                            const Text("👋", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.name,
                          style: AppTextStyles.h1.copyWith(color: AppColors.white, fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              user.city ?? "Sector 18, Noida",
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(height: 80),
                    error: (_, __) => Text("Welcome", style: AppTextStyles.h1.copyWith(color: AppColors.white)),
                  ),
                  const SizedBox(height: 32),
                  // Search Bar
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.primaryBlue, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            "Search for a service...",
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      height: 110,
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

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LIMITED OFFER",
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "20% off your\nfirst booking!",
                style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 24),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "Claim Now",
                  style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),
        ],
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
