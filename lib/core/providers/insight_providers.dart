import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_locator.dart';
import '../../core/providers/habit_providers.dart';

/// Provider for persistent/cached insights.
/// This ONLY re-fetches when dailyLogs change.
final aiInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final logs = await ref.watch(weeklyLogsProvider.future);

  final sleepLogs = logs.where((l) => l.type == 'sleep').toList();
  final waterLogs = logs.where((l) => l.type == 'water').toList();
  final stepsLogs = logs.where((l) => l.type == 'steps').toList();

  return ref
      .read(personalizedInsightsServiceProvider)
      .generateInsights(sleepLogs, waterLogs, stepsLogs);
});
