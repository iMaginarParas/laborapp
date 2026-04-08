import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/providers/language_provider.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Strings.of(context, 'privacy_policy'), style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Terms of Service',
              'Welcome to Laborgro. By using our application, you agree to these terms. Laborgro is a platform that connects workers and customers. We do not employ workers directly and are not responsible for the quality of work performed. Users are advised to verify identity and skills before hiring.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Privacy Policy',
              'Your privacy is important to us. Laborgro collects basic information like your name, phone number, and location to facilitate connections. We hide your phone number from other users to protect you. We do not sell your data to third parties.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'User Conduct',
              'Users must be respectful and provide accurate information. Workers must not misrepresent their skills. Customers must provide a safe working environment. Any reported harassment or fraud will result in immediate account termination.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Payments',
              'Laborgro currently does not handle payments directly within the app. All payments are between the customer and the worker. We recommend using secure methods like UPI only after the work is completed to your satisfaction.',
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Last updated: April 2024',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4.copyWith(color: AppColors.primaryColor)),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, height: 1.6),
        ),
      ],
    );
  }
}
