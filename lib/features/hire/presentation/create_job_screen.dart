import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_layout.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:flutter_app/features/jobs/providers/job_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/core/constants/api_constants.dart';
import 'package:flutter_app/features/main_tabs/providers/navigation_providers.dart';
import 'package:flutter_app/shared/widgets/city_autocomplete_field.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _openingsController = TextEditingController(text: "1");
  
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _openingsController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a category")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final client = ref.read(dioClientProvider);
      final url = ApiConstants.jobs;
      debugPrint("DEBUG: Posting to $url with data...");
      await client.post(url, data: {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'job_city': _cityController.text.trim(),
        'salary_min': double.parse(_salaryMinController.text),
        'salary_max': double.parse(_salaryMaxController.text),
        'openings': int.parse(_openingsController.text),
        'category_id': _selectedCategoryId,
        'lat': 0.0,
        'lng': 0.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job posted successfully!")),
        );
        // Refresh all job lists immediately
        ref.invalidate(jobsProvider);
        ref.invalidate(myPostedJobsProvider);
        
        // Safety: If this screen is a Tab, pop will kill the app. 
        // We check if it's a modal/pushed route first.
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          // Switch to home tab
          ref.read(navigationIndexProvider.notifier).state = 0;
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = "Failed to post job: $e";
        if (e is DioException && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map) {
            errorMsg = data['detail'] ?? data['message'] ?? "Validation failed";
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Post a Job Classified", style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ref.read(navigationIndexProvider.notifier).state = 0;
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Describe the job you're hiring for. Workers will see this in their 'Latest Jobs' feed.",
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              
              _buildLabel("Job Title"),
              const SizedBox(height: 4),
              TextFormField(
                controller: _titleController,
                decoration: AppLayout.commonInputDecoration(hintText: "e.g. Need House Painter for 2 Days"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              _buildLabel("Category"),
              const SizedBox(height: 6),
              ref.watch(categoriesProvider).when(
                data: (cats) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cats.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return FilterChip(
                      label: Text("${cat.emoji} ${cat.name}"),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryColor,
                    );
                  }).toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text("Error loading categories"),
              ),
              const SizedBox(height: 12),

              _buildLabel("Description"),
              const SizedBox(height: 4),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: AppLayout.commonInputDecoration(hintText: "Detail the work, hours, and requirements..."),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              _buildLabel("City"),
              const SizedBox(height: 4),
              CityAutocompleteField(
                controller: _cityController,
                hintText: "e.g. Noida, Sector 62",
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onCitySelected: (city) {
                  _cityController.text = city;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Min Salary (₹)"),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _salaryMinController,
                          keyboardType: TextInputType.number,
                          decoration: AppLayout.commonInputDecoration(hintText: "0").copyWith(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Max Salary (₹)"),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _salaryMaxController,
                          keyboardType: TextInputType.number,
                          decoration: AppLayout.commonInputDecoration(hintText: "1000").copyWith(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel("Number of Openings"),
              const SizedBox(height: 4),
              TextFormField(
                controller: _openingsController,
                keyboardType: TextInputType.number,
                decoration: AppLayout.commonInputDecoration(hintText: "1").copyWith(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: "Post Job",
                isLoading: _isLoading,
                onPressed: _submitJob,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold));
  }
}
