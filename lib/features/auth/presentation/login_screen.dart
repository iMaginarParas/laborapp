import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: "9999999999");
  final _passwordController = TextEditingController(text: "test1234");
  bool _isLoading = false;

  Future<void> _handleLogin() async {
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
          SnackBar(content: Text("Login failed: $e")),
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text("Welcome Back", style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text("Sign in to continue booking your favorite services.", 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
                  const SizedBox(height: 32),
                  _buildLabel("Phone Number or Email"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: "Enter your phone or email",
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Password"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: Icon(Icons.lock_outline, size: 20),
                      suffixIcon: Icon(Icons.visibility_off_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password?", style: AppTextStyles.label.copyWith(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: "Sign In", 
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text("Register Now", style: AppTextStyles.label),
                      ),
                    ],
                  ),
                ],
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
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      padding: const EdgeInsets.only(left: 40, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🛠️", style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
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
