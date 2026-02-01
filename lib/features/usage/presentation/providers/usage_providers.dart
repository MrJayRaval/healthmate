import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';

final todayUsageProvider = FutureProvider.family<int, String>((
  ref,
  featureName,
) async {
  return ref.watch(usageServiceProvider).getTodayUsageCount(featureName);
});

final allTodayUsageProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(usageServiceProvider).getAllTodayUsage();
});
