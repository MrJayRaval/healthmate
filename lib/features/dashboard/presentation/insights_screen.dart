import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/health_chart.dart';
import '../../../core/providers/habit_providers.dart';
import '../../../core/providers/insight_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../usage/presentation/providers/usage_providers.dart';
import '../../usage/data/services/usage_service.dart';
import '../../../core/services/service_locator.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  Future<void> _regenerateInsights() async {
    final usageService = ref.read(usageServiceProvider);
    final currentUsage = await usageService.getTodayUsageCount('insights');

    if (currentUsage >= UsageService.dailyLimit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Daily limit reached for Insights (10/10). Try again tomorrow!',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await usageService.incrementUsage('insights');
    ref.invalidate(todayUsageProvider('insights'));
    ref.invalidate(aiInsightsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(aiInsightsProvider);
    final logsAsync = ref.watch(weeklyLogsProvider);
    final animationsEnabled = ref.watch(animationsProvider);
    final usageAsync = ref.watch(todayUsageProvider('insights'));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Health Insights',
        actions: [
          usageAsync.when(
            data: (count) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '$count/${UsageService.dailyLimit}',
                  style: TextStyle(
                    fontSize: 11,
                    color: count >= UsageService.dailyLimit
                        ? AppColors.error
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          if (insightsAsync.hasValue && insightsAsync.value!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Regenerate Insights',
              onPressed: () {
                ref.invalidate(weeklyLogsProvider);
                _regenerateInsights();
              },
            ),
        ],
      ),
      body: insightsAsync.when(
        data: (insights) {
          final score = insights['overall_score'] ?? 0;
          final tips = insights['insights'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAnimation(
                  type: AnimationType.fadeInDown,
                  enabled: animationsEnabled,
                  child: _buildModernScoreCard(context, score),
                ),
                const SizedBox(height: 32),
                AppAnimation(
                  type: AnimationType.fadeInLeft,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'AI Personalized Tips',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...tips.asMap().entries.map((entry) {
                  final index = entry.key;
                  final text = entry.value;
                  return AppAnimation(
                    type: AnimationType.fadeInLeft,
                    enabled: animationsEnabled,
                    delay: Duration(milliseconds: 300 + (index * 100)),
                    child: _InsightTile(text: text),
                  );
                }),
                if (tips.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Logging habits will unlock AI insights!"),
                    ),
                  ),
                const SizedBox(height: 24),
                // Regenerate Button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _regenerateInsights(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Regenerate Insights'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppAnimation(
                  type: AnimationType.fadeInLeft,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    'Activity Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                logsAsync.when(
                  data: (logs) {
                    final stepsLogs = logs
                        .where((l) => l.type == 'steps')
                        .toList();
                    final sleepLogs = logs
                        .where((l) => l.type == 'sleep')
                        .toList();
                    return Column(
                      children: [
                        if (stepsLogs.isNotEmpty)
                          AppAnimation(
                            type: AnimationType.fadeInUp,
                            enabled: animationsEnabled,
                            delay: const Duration(milliseconds: 700),
                            child: HealthChart(
                              logs: stepsLogs,
                              title: 'Steps This Week',
                              color: Colors.orange,
                            ),
                          ),
                        if (stepsLogs.isNotEmpty && sleepLogs.isNotEmpty)
                          const SizedBox(height: 24),
                        if (sleepLogs.isNotEmpty)
                          AppAnimation(
                            type: AnimationType.fadeInUp,
                            enabled: animationsEnabled,
                            delay: const Duration(milliseconds: 800),
                            child: HealthChart(
                              logs: sleepLogs,
                              title: 'Sleep This Week',
                              color: Colors.indigo,
                            ),
                          ),
                        if (stepsLogs.isEmpty && sleepLogs.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "No activity data yet. Start logging!",
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Trends error: $e')),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading insights: $e')),
      ),
    );
  }

  Widget _buildModernScoreCard(BuildContext context, int score) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.favorite_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'WEEKLY SCORE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          score > 70 ? 'Excellent' : 'Improving',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatefulWidget {
  final String text;
  const _InsightTile({required this.text});

  @override
  State<_InsightTile> createState() => _InsightTileState();
}

class _InsightTileState extends State<_InsightTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final IconData icon = _getIconForTip(widget.text);
    final Color color = _getColorForTip(widget.text);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getHeaderForTip(widget.text),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.text,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          if (widget.text.length > 80)
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  isExpanded ? 'Show Less' : 'Show More',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForTip(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('water') || lower.contains('hydrat')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('sleep') || lower.contains('rest')) {
      return Icons.bedtime_rounded;
    }
    if (lower.contains('step') ||
        lower.contains('walk') ||
        lower.contains('move')) {
      return Icons.directions_walk_rounded;
    }
    return Icons.auto_awesome;
  }

  Color _getColorForTip(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('water')) return Colors.cyan;
    if (lower.contains('sleep')) return Colors.indigo;
    if (lower.contains('step')) return Colors.orange;
    return AppColors.primary;
  }

  String _getHeaderForTip(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('water')) return 'Hydration Goal';
    if (lower.contains('sleep')) return 'Rest & Recovery';
    if (lower.contains('step')) return 'Daily Movement';
    return 'Smart Improvement';
  }
}
