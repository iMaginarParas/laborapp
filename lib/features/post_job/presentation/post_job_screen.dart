import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/shared/models/worker.dart' as model;

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _wageController = TextEditingController();
  final _skillsController = TextEditingController();
  
  List<String> _skills = [];
  final List<int> _selectedCategoryIds = [];

  void _toggleCategory(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _addSkill(String skill) {
    if (skill.trim().isNotEmpty && !_skills.contains(skill.trim())) {
      setState(() {
        _skills.add(skill.trim());
        _skillsController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _wageController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Create Worker Profile", style: AppTextStyles.h2.copyWith(color: AppColors.primaryBlue, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Set up your work profile to start receiving bookings. "
                "Provide details about what services you offer.",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 32),
              
              // 1. About / Summary
              _buildSectionTitle("About You (Summary)"),
              const SizedBox(height: 12),
              TextFormField(
                controller: _aboutController,
                maxLines: 4,
                decoration: _inputDecoration("E.g., Professional painter with 5+ years experience..."),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              // 2. Categories
              _buildSectionTitle("Which category of work do you do?"),
              const SizedBox(height: 12),
              ref.watch(categoriesProvider).when(
                data: (categories) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategoryIds.contains(cat.id);
                    return FilterChip(
                      label: Text("${cat.emoji} ${cat.name}"),
                      selected: isSelected,
                      onSelected: (_) => _toggleCategory(cat.id),
                      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryBlue,
                      labelStyle: AppTextStyles.label.copyWith(
                        color: isSelected ? AppColors.primaryBlue : AppColors.muted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.transparent),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text("Failed to load categories"),
              ),
              const SizedBox(height: 24),
              
              // 3. Skills
              _buildSectionTitle("Skills"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillsController,
                      decoration: _inputDecoration("Add a skill (e.g., Interior Painting)"),
                      onFieldSubmitted: _addSkill,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _addSkill(_skillsController.text),
                    icon: const Icon(Icons.add_circle, color: AppColors.primaryBlue, size: 32),
                  )
                ],
              ),
              if (_skills.isNotEmpty) const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) => Chip(
                  label: Text(skill, style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue)),
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  side: BorderSide.none,
                  deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primaryBlue),
                  onDeleted: () => _removeSkill(skill),
                )).toList(),
              ),
              const SizedBox(height: 24),
              
              // 3. Location
              _buildSectionTitle("Location"),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration("E.g., Noida, Uttar Pradesh").copyWith(
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.muted),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                   // 4. Experience
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Experience"),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Years (e.g., 5)"),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 5. Wage Per Hour
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Hourly Wage (₹)"),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _wageController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("₹/hr (e.g., 450)"),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text("Post Profile & Start Working", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(fontSize: 16),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_skills.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add at least one skill.")),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        final repository = ref.read(authRepositoryProvider);
        await repository.updateProfile({
          "bio": _aboutController.text.trim(),
          "skills": _skills,
          "category_ids": _selectedCategoryIds,
          "city": _locationController.text.trim(),
          "experience_years": int.tryParse(_experienceController.text) ?? 1,
          "hourly_rate": double.tryParse(_wageController.text) ?? 500.0,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile details saved successfully!")),
          );
          // Optional: invalidate currentUserProvider to refresh global user data
          ref.invalidate(currentUserProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update profile: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
