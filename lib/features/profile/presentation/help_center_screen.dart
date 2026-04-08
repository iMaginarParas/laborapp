import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Strings.of(context, 'help_center'), style: AppTextStyles.h3),
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
            _buildContactCard(
              context,
              title: 'Contact Support',
              subtitle: 'Our team is here to help you 24/7',
              email: 'laborgrow@gmail.com',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 32),
            Text('Frequently Asked Questions', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildFaqItem(
              context,
              'How do I hire a worker?',
              'Choose a category from the home screen, find a worker you like, and click "Hire Now" or "Chat" to discuss the job.',
            ),
            _buildFaqItem(
              context,
              'How do I register as a worker?',
              'Go to your profile, click on "Professional Profile", and complete your work details including skills and price.',
            ),
            _buildFaqItem(
              context,
              'Is my phone number safe?',
              'Yes! Laborgro hides your phone number. All calls and chats happen through our secure in-app system.',
            ),
            _buildFaqItem(
              context,
              'How do I pay the worker?',
              'Currently, you can pay workers directly via cash or UPI after the work is complete. Always verify the work before payment.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.0 (Stable)',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, {required String title, required String subtitle, required String email, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4.copyWith(color: AppColors.white)),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: email,
                query: 'subject=Support Request - Laborgro',
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  email,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paleBlue),
      ),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(answer, style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted, height: 1.5)),
        ],
      ),
    );
  }
}
