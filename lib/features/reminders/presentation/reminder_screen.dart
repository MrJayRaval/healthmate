import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/reminder_providers.dart';
import '../../../core/services/service_locator.dart';
import '../data/models/reminder.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reminders',
        actions: [
          IconButton(
            onPressed: () => _showReminderModal(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: remindersAsync.when(
        data: (reminders) => reminders.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return _ReminderTile(reminder: reminder);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString().contains('404')
                      ? 'The reminders table was not found in the database.'
                      : 'Check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(remindersProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'No reminders set',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a reminder for your medications or water.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showReminderModal(
    BuildContext context,
    WidgetRef ref, [
    Reminder? existingReminder,
  ]) {
    final titleController = TextEditingController(
      text: existingReminder?.title,
    );
    TimeOfDay selectedTime = TimeOfDay.now();

    if (existingReminder != null) {
      final parts = existingReminder.scheduledTime.split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    String selectedType = existingReminder?.type ?? 'medication';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    existingReminder == null ? 'New Reminder' : 'Edit Reminder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (existingReminder != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Reminder?'),
                            content: const Text(
                              'Are you sure you want to delete this reminder?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(reminderRepositoryProvider)
                              .deleteReminder(existingReminder.id);
                          ref.invalidate(remindersProvider);
                          if (context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reminder deleted')),
                            );
                          }
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  hintText: 'e.g. Morning Vitamin',
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notification Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    icon: const Icon(Icons.access_time_rounded),
                    label: Text(selectedTime.format(context)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['medication', 'water', 'sleep', 'other'].map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Text(type.toUpperCase()),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setModalState(() => selectedType = type);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a title'),
                              ),
                            );
                            return;
                          }

                          try {
                            setModalState(() => isSaving = true);

                            final authService = ref.read(authServiceProvider);
                            final user = authService.currentUser;

                            if (user == null) {
                              throw Exception('User session not found.');
                            }

                            final reminder = Reminder(
                              id: existingReminder?.id ?? '',
                              userId: user.id,
                              title: titleController.text.trim(),
                              scheduledTime:
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              type: selectedType,
                              isActive: existingReminder?.isActive ?? true,
                            );

                            if (existingReminder == null) {
                              await ref
                                  .read(reminderRepositoryProvider)
                                  .addReminder(reminder);
                            } else {
                              await ref
                                  .read(reminderRepositoryProvider)
                                  .updateReminder(reminder);
                            }

                            // Schedule local notification
                            try {
                              final now = DateTime.now();
                              var reminderDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );

                              if (reminderDateTime.isBefore(now)) {
                                reminderDateTime = reminderDateTime.add(
                                  const Duration(days: 1),
                                );
                              }

                              await ref
                                  .read(notificationServiceProvider)
                                  .scheduleNotification(
                                    id: titleController.text.hashCode,
                                    title:
                                        'HealthMate Reminder: ${selectedType.toUpperCase()}',
                                    body:
                                        'It\'s time for: ${titleController.text}',
                                    scheduledTime: reminderDateTime,
                                  );
                            } catch (e) {
                              debugPrint('Notification failed: $e');
                            }

                            ref.invalidate(remindersProvider);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    existingReminder == null
                                        ? 'Reminder added!'
                                        : 'Reminder updated!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          existingReminder == null
                              ? 'Save Reminder'
                              : 'Update Reminder',
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  final Reminder reminder;
  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () =>
          ReminderScreen()._showReminderModal(context, ref, reminder),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTypeColor(reminder.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(reminder.type),
                color: _getTypeColor(reminder.type),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatTime(reminder.scheduledTime),
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: reminder.isActive,
              onChanged: (val) async {
                try {
                  await ref
                      .read(reminderRepositoryProvider)
                      .toggleReminder(reminder.id, val);
                  ref.invalidate(remindersProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:${minute.toString().padLeft(2, '0')} $ampm';
    } catch (e) {
      return time;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'medication':
        return Icons.medication_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'sleep':
        return Icons.bed_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'medication':
        return Colors.redAccent;
      case 'water':
        return Colors.blue;
      case 'sleep':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }
}
