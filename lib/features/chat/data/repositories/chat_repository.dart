import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository(this._supabase);

  Future<List<ChatMessage>> getChatHistory() async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro fetching chat history: $e');
      return [];
    }
  }

  Future<void> saveMessage(ChatMessage message) async {
    try {
      await _supabase.from('chat_messages').insert(message.toJson());
    } catch (e) {
      print('Error saving message: $e');
    }
  }
}
