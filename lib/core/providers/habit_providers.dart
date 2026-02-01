import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_locator.dart';
import '../../features/habit_tracker/data/models/health_log.dart';

final weeklyLogsProvider = FutureProvider<List<HealthLog>>((ref) async {
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 7));
  return ref.read(habitRepositoryProvider).getLogsForDateRange(start, now);
});

final healthScoreProvider = Provider<AsyncValue<int>>((ref) {
  final weeklyLogs = ref.watch(weeklyLogsProvider);

  return weeklyLogs.whenData((logs) {
    if (logs.isEmpty) return 70;

    final sleepLogs = logs.where((l) => l.type == 'sleep').toList();
    final waterLogs = logs.where((l) => l.type == 'water').toList();
    final stepsLogs = logs.where((l) => l.type == 'steps').toList();

    double sleepAvg = sleepLogs.isEmpty
        ? 0
        : sleepLogs.map((e) => e.value).reduce((a, b) => a + b) / 7;
    double stepsAvg = stepsLogs.isEmpty
        ? 0
        : stepsLogs.map((e) => e.value).reduce((a, b) => a + b) / 7;

    int score = 65;
    if (sleepAvg >= 7) score += 10;
    if (stepsAvg >= 5000) score += 15;
    if (waterLogs.isNotEmpty) score += 10;

    return score.clamp(0, 100);
  });
});
