import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import '../../../core/utils/api_error_handler.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(); // Cleared initial value
  final _passwordController = TextEditingController(); // Cleared initial value
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true; // Added for eye toggle

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      SnackBarUtils.showError(context, "Please enter both email and password");
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final token = await ref.read(authRepositoryProvider).login(
        _emailController.text,
        _passwordController.text,
      );
      ref.read(authStateProvider.notifier).state = token;
      if (mounted) {
        // Just pop or let the app state change handle it
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, ApiErrorHandler.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '257460994920-oe4o0s30oigen7irlfqpc8dciluruk0k.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      final account = await googleSignIn.signIn();

      if (account == null) {
        // User cancelled the sign-in
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        if (mounted) {
          SnackBarUtils.showError(context, "Failed to get Google credentials. Please try again.");
        }
        return;
      }

      // Send the ID token to our backend for verification
      final token = await ref.read(authRepositoryProvider).loginWithGoogle(idToken);
      ref.read(authStateProvider.notifier).state = token;
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, ApiErrorHandler.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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
                    _buildLabel("Email Address"),
                    AppLayout.height8,
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Enter your email address",
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
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
                    AppLayout.height24,
                    PrimaryButton(
                      text: "Sign In", 
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    AppLayout.height24,
                    _buildDividerWithText("or"),
                    AppLayout.height24,
                    _buildGoogleButton(),
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

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.radius12),
          ),
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Google logo asset
                  Image.asset(
                    'assets/google_logo.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Continue with Google",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
