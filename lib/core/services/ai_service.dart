import 'package:dio/dio.dart';

class AIService {
  final Dio _dio = Dio();
  String? _apiKey;
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // High-speed, high-intelligence model
  final String _model = 'llama-3.3-70b-versatile';

  bool _isInitialized = false;

  void initialize(String apiKey) {
    if (apiKey.isEmpty) {
      print('AI API Key is missing');
      return;
    }
    _apiKey = apiKey;
    _isInitialized = true;
    print('AIService (Groq) initialized');
  }

  Future<String> generateContent(String prompt) async {
    if (!_isInitialized) throw Exception('AI not initialized');

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        },
      );

      return response.data['choices'][0]['message']['content'] ??
          'No response.';
    } catch (e) {
      print('Groq AI Error: $e');
      return 'I’m sorry, I’m having trouble connecting to my AI brain. Please check your API key.';
    }
  }

  /// Specialized method for structured symptom analysis
  Future<String> analyzeSymptoms(String input) async {
    final prompt =
        '''
    Act as a medical triage AI. Analyze these symptoms: "$input".
    Return ONLY a raw JSON object (no markdown) with this structure:
    {
      "urgency": "High" | "Medium" | "Low",
      "advisory": "Brief medical advice (max 2 sentences)",
      "detected_symptoms": ["list", "of", "symptoms"],
      "color_code": "0xFF..."
    }
    ''';

    return await generateContent(prompt);
  }

  /// Chat capability
  Stream<String> generateChatStream(
    List<dynamic> history,
    String newMessage,
  ) async* {
    if (!_isInitialized) {
      yield 'AI not initialized.';
      return;
    }

    try {
      final messages = history
          .map(
            (h) => {'role': h.isUser ? 'user' : 'assistant', 'content': h.text},
          )
          .toList();

      messages.add({'role': 'user', 'content': newMessage});

      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {'model': _model, 'messages': messages, 'temperature': 0.7},
      );

      yield response.data['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      yield 'Error: $e';
    }
  }
}
