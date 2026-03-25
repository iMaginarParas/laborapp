import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/models/job.dart';
import 'package:flutter_app/shared/widgets/badge_pill.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:flutter_app/shared/widgets/job_card.dart';
import 'package:flutter_app/features/worker_profile/presentation/worker_profile_screen.dart';
import 'package:flutter_app/features/booking/presentation/booking_screen.dart';
import 'package:flutter_app/features/jobs/presentation/job_detail_screen.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_app/core/services/voice_service.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(autoStartVoiceProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(autoStartVoiceProvider.notifier).state = false;
          _triggerVoiceSearch();
        }
      });
    }

    void showWorkingOnIt() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.of(context, 'working_on_it')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
    final currentRole = ref.watch(currentRoleProvider);
    final selectedFilter = ref.watch(searchFilterProvider);
    final isHireRole = currentRole == UserRole.hire;

    final workersAsync = isHireRole ? ref.watch(searchWorkersProvider) : null;
    final jobsAsync = !isHireRole ? ref.watch(searchJobsProvider) : null;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isHireRole),
            _buildSearchBar(context, isHireRole),
            _buildFilterChips(context, selectedFilter, isHireRole),
            Expanded(
              child: isHireRole 
                  ? _buildWorkersList(workersAsync!) 
                  : _buildJobsList(jobsAsync!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isHireRole) {
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
          Text(
            isHireRole ? Strings.of(context, 'find_workers') : Strings.of(context, 'available_jobs'), 
            style: AppTextStyles.h2
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isHireRole) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.paleBlue,
          borderRadius: BorderRadius.circular(16),
          border: _isListening ? Border.all(color: AppColors.primaryColor, width: 2) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: _isListening ? AppColors.primaryColor : AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: _isListening ? "Listening..." : (isHireRole ? Strings.of(context, 'find_workers_hint') : Strings.of(context, 'find_jobs_hint')),
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: _isListening ? AppColors.primaryColor : AppColors.muted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
            GestureDetector(
              onTap: _triggerVoiceSearch,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.primaryColor : AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_isListening) BoxShadow(color: AppColors.primaryColor.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.white : AppColors.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, SearchFilter selected, bool isHireRole) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _buildChip("All", SearchFilter.all, selected == SearchFilter.all),
          if (isHireRole) ...[
            _buildChip(Strings.of(context, 'available_now'), SearchFilter.availableNow, selected == SearchFilter.availableNow),
            _buildChip(Strings.of(context, 'top_rated'), SearchFilter.topRated, selected == SearchFilter.topRated),
            _buildChip(Strings.of(context, 'lowest_price'), SearchFilter.lowestPrice, selected == SearchFilter.lowestPrice),
          ] else ...[
            _buildChip(Strings.of(context, 'highest_paying'), SearchFilter.topRated, selected == SearchFilter.topRated),
            _buildChip(Strings.of(context, 'latest_posts'), SearchFilter.recentlyPosted, selected == SearchFilter.recentlyPosted),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, SearchFilter filter, bool isActive) {
    return GestureDetector(
      onTap: () => ref.read(searchFilterProvider.notifier).state = filter,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isActive ? AppColors.primaryColor : AppColors.border),
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
        ? _buildEmptyState("No workers found", "Try keywords like 'Painter'")
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: workers.length,
            itemBuilder: (context, index) => _SearchWorkerCard(worker: workers[index]),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildJobsList(AsyncValue<List<Job>> asyncValue) {
    return asyncValue.when(
      data: (jobs) => jobs.isEmpty 
        ? _buildEmptyState("No jobs found", "Try keywords like 'Cleaning'")
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: jobs.length,
            itemBuilder: (context, index) => JobCard(
              job: jobs[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => JobDetailScreen(job: jobs[index])),
                );
              },
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _triggerVoiceSearch() {
    if (_isListening) {
      VoiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      VoiceService.startListening(
        onResult: (text) {
          setState(() {
            _searchController.text = text;
            _searchController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
          });
          ref.read(searchQueryProvider.notifier).state = text;
        },
        onListeningChange: (val) {
          if (mounted) setState(() => _isListening = val);
        },
      );
    }
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
                  child: Text(worker.categories.isEmpty ? "👷" : worker.categories.first.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name, style: AppTextStyles.h3.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text("${worker.categories.isEmpty ? 'Worker' : worker.categories.first.name} • ${worker.experienceYears}+ yrs experience", 
                        style: AppTextStyles.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (worker.isVerified)
                             BadgePill(
                              label: Strings.of(context, 'verified'), 
                              icon: Icons.check_circle, 
                              color: AppColors.successGreen,
                              backgroundColor: AppColors.greenBG,
                            ),
                          if (worker.isAvailable) ...[
                            const SizedBox(width: 8),
                             BadgePill(
                              label: Strings.of(context, 'available_now'), 
                              icon: Icons.bolt, 
                              color: AppColors.primaryColor,
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
                          TextSpan(text: "₹${worker.hourlyRate.toInt()} / ", style: AppTextStyles.h3.copyWith(color: AppColors.primaryColor)),
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
