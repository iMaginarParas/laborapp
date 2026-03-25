import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_layout.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter_app/shared/widgets/city_autocomplete_field.dart';

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
  bool _prefilled = false;

  /// Pre-fill form fields from the user's existing saved profile data.
  void _prefillFromUser() {
    final userAsync = ref.read(currentUserProvider);
    userAsync.whenData((user) {
      if (_prefilled) return;
      _prefilled = true;

      // City
      if (user.city != null && user.city!.isNotEmpty) {
        _locationController.text = user.city!;
      }

      // Skills (stored as plain list of strings on employee table)
      if (user.skills.isNotEmpty) {
        setState(() {
          _skills = List<String>.from(user.skills);
        });
      }

      // Work details (bio, categories, experience, hourly_rate)
      final wd = user.workDetails;
      if (wd != null) {
        if (wd['bio'] != null) {
          _aboutController.text = wd['bio'].toString();
        }
        if (wd['experience_years'] != null) {
          _experienceController.text = wd['experience_years'].toString();
        }
        if (wd['hourly_rate'] != null) {
          final rate = wd['hourly_rate'];
          // Show as integer if it's a whole number
          final formatted = (rate is double && rate == rate.truncateToDouble())
              ? rate.toInt().toString()
              : rate.toString();
          _wageController.text = formatted;
        }
        final rawCats = wd['category_ids'];
        if (rawCats is List && rawCats.isNotEmpty) {
          setState(() {
            _selectedCategoryIds
              ..clear()
              ..addAll(rawCats.map((e) => int.tryParse(e.toString()) ?? 0).where((id) => id > 0));
          });
        }
      }
    });
  }

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
  void initState() {
    super.initState();
    // Defer pre-fill to after the first frame so ref.read is safe
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromUser());
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

  /// Whether the worker already has an existing profile
  bool get _hasExistingProfile {
    final userAsync = ref.read(currentUserProvider);
    return userAsync.maybeWhen(
      data: (u) => u.workDetails != null && u.workDetails!['bio'] != null && u.workDetails!['bio'].toString().isNotEmpty,
      orElse: () => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _hasExistingProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Worker Profile" : "Create Worker Profile",
          style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor, fontSize: 20),
        ),
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
                isEdit
                    ? "Update your work profile details below."
                    : "Set up your work profile to start receiving bookings. "
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
                decoration: AppLayout.commonInputDecoration(hintText: "E.g., Professional painter with 5+ years experience..."),
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
                      selectedColor: AppColors.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryColor,
                      labelStyle: AppTextStyles.label.copyWith(
                        color: isSelected ? AppColors.primaryColor : AppColors.muted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: isSelected ? AppColors.primaryColor : Colors.transparent),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Text("Failed to load categories"),
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
                      decoration: AppLayout.commonInputDecoration(hintText: "Add a skill (e.g., Interior Painting)"),
                      onFieldSubmitted: _addSkill,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _addSkill(_skillsController.text),
                    icon: Icon(Icons.add_circle, color: AppColors.primaryColor, size: 32),
                  )
                ],
              ),
              if (_skills.isNotEmpty) const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) => Chip(
                  label: Text(skill, style: AppTextStyles.label.copyWith(color: AppColors.primaryColor)),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  side: BorderSide.none,
                  deleteIcon: Icon(Icons.close, size: 16, color: AppColors.primaryColor),
                  onDeleted: () => _removeSkill(skill),
                )).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Location
              _buildSectionTitle("Location"),
              const SizedBox(height: 12),
              CityAutocompleteField(
                controller: _locationController,
                hintText: "E.g., Noida, Uttar Pradesh",
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onCitySelected: (city) {
                  _locationController.text = city;
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  // 5. Experience
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Experience"),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: AppLayout.commonInputDecoration(hintText: "Years (e.g., 5)"),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 6. Wage Per Hour
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Hourly Wage (₹)"),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _wageController,
                          keyboardType: TextInputType.number,
                          decoration: AppLayout.commonInputDecoration(hintText: "₹/hr (e.g., 450)"),
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
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? "Save Changes" : "Post Profile & Start Working",
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
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
          // Refresh user data so next time this screen opens it pre-fills correctly
          ref.invalidate(currentUserProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_hasExistingProfile
                  ? "Profile updated successfully!"
                  : "Profile saved successfully!"),
              backgroundColor: AppColors.successGreen,
            ),
          );
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
