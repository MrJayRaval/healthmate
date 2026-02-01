class HealthLog {
  final String id;
  final String userId;
  final String type;
  final double value;
  final String? unit;
  final DateTime loggedAt;

  HealthLog({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    this.unit,
    required this.loggedAt,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      loggedAt: DateTime.parse(json['logged_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'value': value,
      'unit': unit,
      'logged_at': loggedAt.toIso8601String(),
    };
  }
}
