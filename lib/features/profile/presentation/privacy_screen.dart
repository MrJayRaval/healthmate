import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Privacy & Security', showLogo: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Data Protection',
              'Your health data is encrypted and stored securely using Supabase. We do not sell your personal information to third parties.',
              Icons.security_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'AI Conversations',
              'Chat history with HealthMate AI is preserved for your continuity but is anonymized when processed for general health insights.',
              Icons.chat_bubble_outline_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Permissions',
              'This app requires access to notifications for reminders and local storage for theme settings. You can manage these in your system settings.',
              Icons.privacy_tip_outlined,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Account Security',
              'Always use a strong password and avoid sharing your account credentials. We recommend changing your password periodically.',
              Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Last Updated: Jan 2026',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(color: Theme.of(context).hintColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}
