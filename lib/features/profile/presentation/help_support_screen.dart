import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Help & Support', showLogo: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How HealthMate Works',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'HealthMate AI is your all-in-one companion for tracking daily health habits and getting AI-powered insights.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            const Text(
              'Table of Contents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTOC(context),

            const SizedBox(height: 48),
            _buildFeatureSection(
              context,
              id: 'habits',
              title: '1. Habit Tracking',
              description:
                  'Track your Sleep, Water, Steps, and Mood. Consistency is key! We use this data to calculate your daily Health Score.',
              icon: Icons.track_changes_rounded,
            ),
            _buildFeatureSection(
              context,
              id: 'symptoms',
              title: '2. Symptom Checker',
              description:
                  'Describe what you feel. Our AI analyzes your inputs to provide general guidance and urgency levels. (Note: Not a medical diagnosis).',
              icon: Icons.medical_services_rounded,
            ),
            _buildFeatureSection(
              context,
              id: 'reminders',
              title: '3. Reminders',
              description:
                  'Set daily reminders for medications, water, or sleep. HealthMate sends you local notifications even when the app is closed.',
              icon: Icons.notifications_rounded,
            ),
            _buildFeatureSection(
              context,
              id: 'chat',
              title: '4. AI Health Chat',
              description:
                  'Ask anything! From recipe ideas to workout tips. Our AI understands naturally spoken language to help you better.',
              icon: Icons.chat_bubble_rounded,
            ),

            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Still need help?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reach out to us at support@healthmate.ai',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTOC(BuildContext context) {
    final items = [
      'Habit Tracking',
      'Symptom Checker',
      'Reminders',
      'AI Health Chat',
      'Contact Support',
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    item,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFeatureSection(
    BuildContext context, {
    required String id,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
