import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/widgets/badge_pill.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:flutter_app/features/worker_profile/presentation/worker_profile_screen.dart';
import 'package:flutter_app/features/booking/presentation/booking_screen.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(searchWorkersProvider);
    final selectedFilter = ref.watch(workerFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(ref),
            _buildFilterChips(ref, selectedFilter),
            Expanded(
              child: _buildWorkersList(workersAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (canPop) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Text("Find Workers", style: AppTextStyles.h2),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.paleBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: "Painter, cleaner, guard...",
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, WorkerFilter selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _buildChip(ref, "All", WorkerFilter.all, selected == WorkerFilter.all),
          _buildChip(ref, "Available Now", WorkerFilter.availableNow, selected == WorkerFilter.availableNow),
          _buildChip(ref, "Top Rated", WorkerFilter.topRated, selected == WorkerFilter.topRated),
          _buildChip(ref, "Lowest Price", WorkerFilter.lowestPrice, selected == WorkerFilter.lowestPrice),
        ],
      ),
    );
  }

  Widget _buildChip(WidgetRef ref, String label, WorkerFilter filter, bool isActive) {
    return GestureDetector(
      onTap: () => ref.read(workerFilterProvider.notifier).state = filter,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isActive ? AppColors.primaryBlue : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.white : AppColors.muted,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkersList(AsyncValue<List<Worker>> asyncValue) {
    return asyncValue.when(
      data: (workers) => workers.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: workers.length,
            itemBuilder: (context, index) => _SearchWorkerCard(worker: workers[index]),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text("No workers found", style: AppTextStyles.h3),
          Text("Try common keywords like 'Painter'", style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _SearchWorkerCard extends StatelessWidget {
  final Worker worker;

  const _SearchWorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerProfileScreen(worker: worker),
            ),
          );
        },
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(worker.categories.first.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name, style: AppTextStyles.h3.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text("${worker.categories.first.name} • ${worker.experienceYears}+ yrs experience", 
                        style: AppTextStyles.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (worker.isVerified)
                            const BadgePill(
                              label: "Verified", 
                              icon: Icons.check_circle, 
                              color: AppColors.successGreen,
                              backgroundColor: AppColors.greenBG,
                            ),
                          if (worker.isAvailable) ...[
                            const SizedBox(width: 8),
                            const BadgePill(
                              label: "Available Now", 
                              icon: Icons.bolt, 
                              color: AppColors.primaryBlue,
                              backgroundColor: AppColors.paleBlue,
                            ),
                          ],
                          const SizedBox(width: 8),
                          BadgePill(
                            label: worker.rating.toString(), 
                            icon: Icons.star_rounded, 
                            color: AppColors.orangeWarning,
                            backgroundColor: AppColors.orangeBG,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "₹${worker.hourlyRate.toInt()} / ", style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue)),
                          TextSpan(text: "hr", style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Text("Min. 2 hours", style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.orangeWarning, size: 14),
                        const Icon(Icons.star, color: AppColors.orangeWarning, size: 14),
                        const Icon(Icons.star, color: AppColors.orangeWarning, size: 14),
                        const Icon(Icons.star, color: AppColors.orangeWarning, size: 14),
                        const Icon(Icons.star, color: AppColors.orangeWarning, size: 14),
                      ],
                    ),
                    Text("128 reviews", style: AppTextStyles.bodySmall.copyWith(color: AppColors.orangeWarning, fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  height: 44,
                  child: PrimaryButton(
                    text: "Book Now", 
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => BookingScreen(worker: worker)));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
