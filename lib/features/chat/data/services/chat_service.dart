import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/ai_service.dart';
import '../models/chat_message.dart';

class ChatService {
  final AIService _ai;
  final SupabaseClient _supabase;

  ChatService(this._supabase, this._ai);

  /// Sends a message and returns AI response stream
  Stream<ChatMessage> sendMessage(String text) async* {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Prompt engineering
    final prompt =
        '''
      You are HealthMate, a helpful, empathetic, and professional AI health assistant.
      User says: "$text"
      Rules:
      1. Keep answers concise (max 3 sentences).
      2. Always include a tiny bit of encouragement.
      3. DISCLAIMER: You are not a doctor.
      4. If the user asks for a diagnosis, advise them to see a doctor.
    ''';

    // 2. Call AI API
    // Note: In a real streaming scenario, we would yield chunks.
    // Here we await the full response for simplicity as per current implementation.
    try {
      final responseText = await _ai.generateContent(prompt);

      // 3. Return AI response
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // Generate temporary ID
        userId: user.id,
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      yield aiMsg;
    } catch (e) {
      // Yield an error message if AI fails, so the UI can show it
      // The UI also has a try-catch, but standardizing here is good.
      throw e;
    }
  }
}
