import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/widgets/category_chip.dart';
import 'package:flutter_app/shared/widgets/worker_card.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/features/worker_profile/presentation/worker_profile_screen.dart';
import 'package:flutter_app/features/search/presentation/search_screen.dart';
import 'package:flutter_app/shared/models/worker.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final workersAsync = ref.watch(workersProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(workersProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSectionHeader("Services", null),
              const SizedBox(height: 16),
              _buildCategories(ref, categoriesAsync, selectedCategory),
              const SizedBox(height: 24),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildSectionHeader("Nearby Workers", "See All"),
              const SizedBox(height: 16),
              _buildWorkersList(workersAsync),
              const SizedBox(height: 100), // Padding for tab bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Good morning, Sunil", 
                        style: AppTextStyles.h2.copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.lightBlue, size: 16),
                          const SizedBox(width: 4),
                          Text("Bengaluru, India", 
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightBlue)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.notifications_none, color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Search bar (tappable)
        Positioned(
          bottom: -28,
          left: 24,
          right: 24,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchScreen()));
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.primaryShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Text("Search for plumbing, cleaning...", 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String? linkText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3),
          if (linkText != null)
            TextButton(
              onPressed: () {},
              child: Text(linkText, style: AppTextStyles.label),
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
        error: (e, s) => Center(child: Text("Error loading categories")),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("LIMITED TIME", 
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text("20% off your\nfirst booking", 
                  style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 20)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("Claim Now", style: AppTextStyles.label),
                ),
              ],
            ),
          ),
          const Icon(Icons.celebration, size: 80, color: AppColors.white),
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
