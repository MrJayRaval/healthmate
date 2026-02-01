import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/symptom_log.dart';

class SymptomRepository {
  final SupabaseClient _client;

  SymptomRepository(this._client);

  Future<void> logSymptom({
    required List<String> symptoms,
    required String urgencyLevel,
    String? advisoryText,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('symptoms_logs').insert({
      'user_id': userId,
      'symptoms': symptoms,
      'urgency_level': urgencyLevel,
      'advisory_text': advisoryText,
      // created_at is default now() in DB
    });
  }

  Future<List<SymptomLog>> getHistory() async {
    final response = await _client
        .from('symptoms_logs')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => SymptomLog.fromJson(e)).toList();
  }
}
