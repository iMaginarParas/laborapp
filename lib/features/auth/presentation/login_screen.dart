import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import '../../../core/utils/api_error_handler.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(); // Cleared initial value
  final _passwordController = TextEditingController(); // Cleared initial value
  bool _isLoading = false;
  bool _obscurePassword = true; // Added for eye toggle

  Future<void> _handleLogin() async {
    if (_phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both phone/email and password")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final token = await ref.read(authRepositoryProvider).login(
        _phoneController.text,
        _passwordController.text,
      );
      ref.read(authStateProvider.notifier).state = token;
      if (mounted) {
        // Just pop or let the app state change handle it
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: AppLayout.screenPaddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppLayout.height16,
                    Text("Welcome Back", style: AppTextStyles.h1),
                    AppLayout.height8,
                    Text("Sign in to continue booking your favorite services.", 
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
                    AppLayout.height32,
                    _buildLabel("Phone Number or Email"),
                    AppLayout.height8,
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: "Enter your phone or email",
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    AppLayout.height24,
                    _buildLabel("Password"),
                    AppLayout.height8,
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    AppLayout.height8,
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, AppLayout.touchTargetSize),
                        ),
                        child: Text("Forgot Password?", style: AppTextStyles.label.copyWith(fontSize: 12)),
                      ),
                    ),
                    AppLayout.height24,
                    PrimaryButton(
                      text: "Sign In", 
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    AppLayout.height24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            child: Text("Register Now", style: AppTextStyles.label),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      padding: const EdgeInsets.only(left: 40, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🛠️", style: TextStyle(fontSize: 50)),
          AppLayout.height16,
          Text("Laborgro", 
            style: AppTextStyles.h1.copyWith(color: AppColors.white, fontSize: 40, letterSpacing: 1)),
          Text("Hyperlocal Service Marketplace", 
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightBlue)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold));
  }
}
