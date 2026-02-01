import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_locator.dart';
import '../../features/reminders/data/models/reminder.dart';

final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  try {
    final repository = ref.watch(reminderRepositoryProvider);
    return await repository.getReminders();
  } catch (e, stack) {
    debugPrint('Error in remindersProvider: $e');
    debugPrint(stack.toString());
    rethrow;
  }
});
