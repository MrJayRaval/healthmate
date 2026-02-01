import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../../usage/presentation/providers/usage_providers.dart';
import '../../usage/data/services/usage_service.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        showLogo: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: 'profile_pic',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.userMetadata?['full_name'] ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI Usage Section
            _buildSectionHeader(context, 'AI Usage Today'),
            Consumer(
              builder: (context, ref, _) {
                final usageAsync = ref.watch(allTodayUsageProvider);
                return usageAsync.when(
                  data: (usage) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildUsageTile(
                          context,
                          'Chat',
                          usage['chat'] ?? 0,
                          Icons.chat_bubble_rounded,
                          Colors.blue,
                        ),
                        const Divider(height: 24),
                        _buildUsageTile(
                          context,
                          'Symptom Checker',
                          usage['symptom_checker'] ?? 0,
                          Icons.medical_services_rounded,
                          Colors.red,
                        ),
                        const Divider(height: 24),
                        _buildUsageTile(
                          context,
                          'Insights',
                          usage['insights'] ?? 0,
                          Icons.insights_rounded,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Settings Section
            _buildSectionHeader(context, 'Settings'),
            _buildSettingTile(
              context,
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
            ),
            _buildSettingTile(
              context,
              icon: Icons.animation_rounded,
              title: 'App Animations',
              trailing: Switch(
                value: ref.watch(animationsProvider),
                onChanged: (val) {
                  ref.read(animationsProvider.notifier).toggleAnimations();
                },
              ),
            ),
            _buildSettingTile(
              context,
              icon: Icons.notifications_rounded,
              title: 'Medication Reminders',
              onTap: () => context.push('/reminders'),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Account'),
            _buildSettingTile(
              context,
              icon: Icons.security_rounded,
              title: 'Privacy & Security',
              onTap: () => context.push('/privacy'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () => context.push('/help'),
            ),

            const SizedBox(height: 40),
            Text(
              'Version 0.1.0',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildUsageTile(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    final limit = UsageService.dailyLimit;
    final percentage = (count / limit).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count/$limit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: count >= limit ? AppColors.error : Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
