import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder.dart';

class ReminderRepository {
  final SupabaseClient _supabase;

  ReminderRepository(this._supabase);

  Future<List<Reminder>> getReminders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('reminders')
          .select()
          .eq('user_id', userId)
          .order('scheduled_time', ascending: true);

      return (response as List).map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('ReminderRepository.getReminders error: $e');
      rethrow;
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      await _supabase.from('reminders').insert(reminder.toJson());
      debugPrint('Reminder added successfully');
    } catch (e) {
      debugPrint('ReminderRepository.addReminder error: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _supabase
        .from('reminders')
        .update(reminder.toJson())
        .eq('id', reminder.id);
  }

  Future<void> deleteReminder(String id) async {
    await _supabase.from('reminders').delete().eq('id', id);
  }

  Future<void> toggleReminder(String id, bool isActive) async {
    await _supabase
        .from('reminders')
        .update({'is_active': isActive})
        .eq('id', id);
  }
}
