import 'package:healthmate/core/services/ai_service.dart';


class SymptomClassificationService {
  final AIService _ai;

  SymptomClassificationService(this._ai);

  Future<Map<String, dynamic>> analyzeSymptoms(String input) async {
    if (input.isEmpty) {
      return {
        'urgency': 'Unclear',
        'advisory': 'No symptoms provided.',
        'color_code': 0xFF9E9E9E,
        'score': 0,
        'detected_symptoms': [],
      };
    }

    // Call AI
    final jsonString = await _ai.analyzeSymptoms(input);

    return _parseAIResponse(jsonString);
  }

  Map<String, dynamic> _parseAIResponse(String response) {
    String urgency = 'Low (Self Care)';
    String advisory = 'Please monitor your symptoms.';
    int color = 0xFF388E3C; // Green default
    List<String> detected = [];

    final lower = response.toLowerCase();

    if (lower.contains('"urgency": "high"')) {
      urgency = 'High (Emergency)';
      color = 0xFFD32F2F;
    } else if (lower.contains('"urgency": "medium"')) {
      urgency = 'Medium (Urgent Care)';
      color = 0xFFF57C00;
    } else if (lower.contains('"urgency": "low"')) {
      urgency = 'Low (Self Care)';
      color = 0xFF388E3C;
    }

    try {
      final start = response.indexOf('"advisory": "');
      if (start != -1) {
        final end = response.indexOf('"', start + 13);
        if (end != -1) {
          advisory = response.substring(start + 13, end);
        }
      }
    } catch (e) {}

    return {
      'urgency': urgency,
      'advisory': advisory,
      'score': 5,
      'detected_symptoms': detected,
      'color_code': color,
    };
  }
}
