class AIUsage {
  final String id;
  final String userId;
  final String featureName;
  final DateTime createdAt;

  AIUsage({
    required this.id,
    required this.userId,
    required this.featureName,
    required this.createdAt,
  });

  factory AIUsage.fromJson(Map<String, dynamic> json) {
    return AIUsage(
      id: json['id'],
      userId: json['user_id'],
      featureName: json['feature_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'feature_name': featureName};
  }
}
