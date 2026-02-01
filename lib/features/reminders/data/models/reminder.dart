class Reminder {
  final String id;
  final String userId;
  final String title;
  final String scheduledTime; // HH:mm format
  final bool isActive;
  final String? type; // 'medication', 'water', 'sleep'

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.scheduledTime,
    this.isActive = true,
    this.type,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'].toString(),
      userId: json['user_id'],
      title: json['title'],
      scheduledTime: json['scheduled_time'] ?? json['time'] ?? '00:00',
      isActive: json['is_active'] ?? true,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'scheduled_time': scheduledTime,
      'is_active': isActive,
      'type': type,
    };
  }
}
