import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late GenerativeModel _model;
  bool _isInitialized = false;
  String? _apiKey;

  // Ordered by preference with different names for different API versions
  final List<String> _candidateModels = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-pro',
    'gemini-1.0-pro',
    'gemini-1.5-pro',
  ];

  void initialize(String apiKey) {
    if (apiKey.isEmpty) {
      print('Gemini API Key is missing');
      return;
    }
    _apiKey = apiKey;

    // Default initialization using first candidate
    _model = GenerativeModel(model: _candidateModels.first, apiKey: _apiKey!);
    _isInitialized = true;
    print('GeminiService initialized with model: ${_candidateModels.first}');
  }

  Future<String> generateContent(String prompt) async {
    if (!_isInitialized) {
      throw Exception('Gemini AI is not initialized');
    }

    final content = [Content.text(prompt)];

    // Try candidate model names (some environments expose different model ids)
    for (final modelName in _candidateModels) {
      try {
        print('Attempting Gemini with model: $modelName');
        final tempModel = GenerativeModel(model: modelName, apiKey: _apiKey!);

        final response = await tempModel.generateContent(content);

        if (response.text != null && response.text!.isNotEmpty) {
          _model = tempModel; // Save the successful configuration
          print('Successfully connected using $modelName');
          return response.text!;
        }
      } catch (e) {
        print(
          'Gemini model $modelName failed: ${e.toString().split('\n').first}',
        );
        // Continue to next candidate
      }
    }

    return 'I’m sorry, I’m having trouble connecting to my AI brain. This usually happens if the API key is restricted or the region is unsupported. Please try again later.';
  }

  /// Specialized method for structured symptom analysis
  Future<String> analyzeSymptoms(String input) async {
    if (!_isInitialized) {
      return '{"urgency": "Unclear", "advisory": "AI not active."}';
    }

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

  Stream<String> generateChatStream(List<Content> history, String newMessage) {
    if (!_isInitialized) return Stream.value('AI not initialized.');

    try {
      // Note: startChat uses the _model which was updated to a working version by generateContent
      final chat = _model.startChat(history: history);
      return chat
          .sendMessageStream(Content.text(newMessage))
          .map((r) => r.text ?? '');
    } catch (e) {
      return Stream.value('Error starting AI chat: $e');
    }
  }
}
