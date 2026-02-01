import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/providers/habit_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/health_chart.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? 'Alex';
    final animationsEnabled = ref.watch(animationsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'HealthMate',
        actions: [
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Hero(
              tag: 'profile_pic',
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppAnimation(
              type: AnimationType.fadeInDown,
              enabled: animationsEnabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Daily Health Score (Glassmorphism look)
            AppAnimation(
              type: AnimationType.fadeIn,
              enabled: animationsEnabled,
              duration: const Duration(milliseconds: 1000),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.healthGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ref
                    .watch(healthScoreProvider)
                    .when(
                      data: (score) =>
                          _buildScoreVisual(score, animationsEnabled),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (e, s) =>
                          const Icon(Icons.error, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            AppAnimation(
              type: AnimationType.fadeInRight,
              enabled: animationsEnabled,
              child: Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 100),
                  child: _QuickActionCard(
                    icon: Icons.medical_services_rounded,
                    label: 'Symptom\nChecker',
                    color: AppColors.primary,
                    onTap: () => context.go('/symptoms'),
                  ),
                ),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 200),
                  child: _QuickActionCard(
                    icon: Icons.track_changes_rounded,
                    label: 'Habit\nTracker',
                    color: AppColors.secondary,
                    onTap: () => context.go('/habits'),
                  ),
                ),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 300),
                  child: _QuickActionCard(
                    icon: Icons.notifications_active_rounded,
                    label: 'Medication\nReminders',
                    color: AppColors.accent,
                    onTap: () => context.push('/reminders'),
                  ),
                ),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 400),
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble_rounded,
                    label: 'AI Chat\nAssistant',
                    color: AppColors.secondary,
                    onTap: () => context.go('/chat'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            AppAnimation(
              type: AnimationType.fadeInLeft,
              enabled: animationsEnabled,
              child: Text(
                'Weekly Summary',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            AppAnimation(
              type: AnimationType.fadeInUp,
              enabled: animationsEnabled,
              delay: const Duration(milliseconds: 500),
              child: ref
                  .watch(weeklyLogsProvider)
                  .when(
                    data: (logs) {
                      final stepsLogs = logs
                          .where((l) => l.type == 'steps')
                          .toList();
                      return HealthChart(
                        logs: stepsLogs,
                        title: 'Steps Highlights',
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreVisual(int score, bool animationsEnabled) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Health Score',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppAnimation(
                type: AnimationType.elasticIn,
                enabled: animationsEnabled,
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  score >= 80
                      ? 'Excellent!'
                      : score >= 50
                      ? 'Good!'
                      : 'Keep Improving!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              AppAnimation(
                type: AnimationType.flash,
                enabled: animationsEnabled,
                infinite: true,
                duration: const Duration(seconds: 3),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
