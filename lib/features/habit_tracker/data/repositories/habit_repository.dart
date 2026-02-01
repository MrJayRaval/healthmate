import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_log.dart';

class HabitRepository {
  final SupabaseClient _client;

  HabitRepository(this._client);

  Future<void> logHealthData({
    required String type,
    required double value,
    String? unit,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('health_logs').insert({
      'user_id': userId,
      'type': type,
      'value': value,
      'unit': unit,
      'logged_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<HealthLog>> getDailyLogs(DateTime date) async {
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final response = await _client
        .from('health_logs')
        .select()
        .gte('logged_at', startOfDay)
        .lte('logged_at', endOfDay)
        .order('logged_at', ascending: false);

    return (response as List).map((e) => HealthLog.fromJson(e)).toList();
  }

  Future<List<HealthLog>> getLogsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final response = await _client
        .from('health_logs')
        .select()
        .gte('logged_at', start.toIso8601String())
        .lte('logged_at', end.toIso8601String())
        .order('logged_at', ascending: true);

    return (response as List).map((e) => HealthLog.fromJson(e)).toList();
  }
}
