class SymptomLog {
  final String id;
  final String userId;
  final List<String> symptoms;
  final String urgencyLevel;
  final String? advisoryText;
  final DateTime createdAt;

  SymptomLog({
    required this.id,
    required this.userId,
    required this.symptoms,
    required this.urgencyLevel,
    this.advisoryText,
    required this.createdAt,
  });

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'],
      userId: json['user_id'],
      symptoms: List<String>.from(json['symptoms']),
      urgencyLevel: json['urgency_level'],
      advisoryText: json['advisory_text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symptoms': symptoms,
      'urgency_level': urgencyLevel,
      'advisory_text': advisoryText,
    };
  }
}
