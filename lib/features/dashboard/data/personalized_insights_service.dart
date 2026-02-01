import '../../../core/services/ai_service.dart';

class PersonalizedInsightsService {
  final AIService _ai;

  PersonalizedInsightsService(this._ai);

  /// Analyze health trends using Groq/AI
  Future<Map<String, dynamic>> generateInsights(
    List<dynamic> sleepLogs,
    List<dynamic> waterLogs,
    List<dynamic> stepsLogs,
  ) async {
    // 1. Calculate basic stats first (Context for AI)
    final sleepAvg = _calculateAvg(sleepLogs);
    final waterAvg = _calculateAvg(waterLogs);
    final stepsAvg = _calculateAvg(stepsLogs);

    // 2. Ask AI for analysis
    final prompt =
        "Analyze these 7-day averages for a health app: Sleep: ${sleepAvg.toStringAsFixed(1)}h, Water: ${waterAvg.toInt()}ml, Steps: ${stepsAvg.toInt()}. Generate 3 concise, highly personalized health tips. Return ONLY the tips without any headers or intro.";

    List<String> tips = [];
    try {
      final aiTips = await _ai.generateContent(prompt);
      tips = aiTips
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.replaceAll(RegExp(r'^[-*•] '), ''))
          .take(3)
          .toList();
    } catch (e) {
      tips = ["Stay consistent!", "Drink more water.", "Keep moving!"];
    }

    if (tips.isEmpty) {
      tips = ["Stay consistent!", "Drink more water.", "Keep moving!"];
    }

    return {
      'overall_score': _calculateScore(sleepAvg, waterAvg, stepsAvg),
      'insights': tips,
    };
  }

  double _calculateAvg(List<dynamic> logs) {
    if (logs.isEmpty) return 0.0;
    double total = 0;
    for (var log in logs) {
      try {
        total += (log.value as num).toDouble();
      } catch (e) {}
    }
    return total / 7; // Average over the week
  }

  int _calculateScore(double s, double w, double st) {
    int score = 65;
    if (s >= 7) score += 10;
    if (w >= 2000) score += 10;
    if (st >= 8000) score += 15;
    return score.clamp(0, 100);
  }
}
