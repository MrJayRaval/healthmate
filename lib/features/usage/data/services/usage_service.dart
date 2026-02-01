import 'package:supabase_flutter/supabase_flutter.dart';

class UsageService {
  final SupabaseClient _supabase;

  UsageService(this._supabase);

  static const int dailyLimit = 10;

  Future<int> getTodayUsageCount(String featureName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final today = DateTime.now().toUtc();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    try {
      final response = await _supabase
          .from('ai_usage')
          .select('id')
          .eq('user_id', userId)
          .eq('feature_name', featureName)
          .gte('created_at', startOfDay);

      return (response as List).length;
    } catch (e) {
      print('Error getting usage count: $e');
      return 0;
    }
  }

  Future<bool> incrementUsage(String featureName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('ai_usage').insert({
        'user_id': userId,
        'feature_name': featureName,
      });
      return true;
    } catch (e) {
      print('Error incrementing usage: $e');
      return false;
    }
  }

  Future<Map<String, int>> getAllTodayUsage() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final today = DateTime.now().toUtc();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    try {
      final response = await _supabase
          .from('ai_usage')
          .select('feature_name')
          .eq('user_id', userId)
          .gte('created_at', startOfDay);

      final List data = response as List;
      final Map<String, int> counts = {
        'chat': 0,
        'symptom_checker': 0,
        'insights': 0,
      };

      for (var item in data) {
        final feature = item['feature_name'] as String;
        counts[feature] = (counts[feature] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting all usage: $e');
      return {};
    }
  }
}
