import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import '../../../core/utils/api_error_handler.dart';
import '../../../shared/widgets/city_autocomplete_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final String _selectedRole = "employer"; // Only allowing customer signup
  bool _isLoading = false;
  bool _obscurePassword = true; // Added for eye toggle

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || 
        _phoneController.text.isEmpty || _passwordController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        city: _cityController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Please login.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorHandler.getErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: AppLayout.screenPaddingAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Create Account", style: AppTextStyles.h1),
                  AppLayout.height8,
                  Text("Join Laborgro and find the best hyperlocal services.", 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
                  AppLayout.height24,
                  
                  _buildLabel("Full Name"),
                  AppLayout.height8,
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: "Enter your full name"),
                  ),
                  AppLayout.height16,

                  _buildLabel("Email Address"),
                  AppLayout.height8,
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: "Enter your email"),
                  ),
                  AppLayout.height16,

                  _buildLabel("Phone Number"),
                  AppLayout.height8,
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: "Enter your phone number"),
                  ),
                  AppLayout.height16,

                  _buildLabel("City"),
                  AppLayout.height8,
                  CityAutocompleteField(
                    controller: _cityController,
                    hintText: "Enter your city (e.g. Noida)",
                    onCitySelected: (city) {
                      _cityController.text = city;
                    },
                  ),
                  AppLayout.height16,

                  _buildLabel("Password"),
                  AppLayout.height8,
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Create a password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  AppLayout.height32,

                  PrimaryButton(
                    text: "Register Now", 
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.only(left: AppLayout.space24, bottom: AppLayout.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Join Us", 
            style: AppTextStyles.h1.copyWith(color: AppColors.white, fontSize: 32)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold));
  }
}
