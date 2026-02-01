class ChatMessage {
  final String id;
  final String userId;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['is_user'] ?? false,
      timestamp: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'text': text, 'is_user': isUser};
  }
}
