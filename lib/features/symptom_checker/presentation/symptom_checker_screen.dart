import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../usage/presentation/providers/usage_providers.dart';
import '../../usage/data/services/usage_service.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  void _analyze() async {
    if (_controller.text.trim().isEmpty) return;

    // Check usage limit
    final usageService = ref.read(usageServiceProvider);
    final currentUsage = await usageService.getTodayUsageCount(
      'symptom_checker',
    );

    if (currentUsage >= UsageService.dailyLimit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Daily limit reached for Symptom Checker (10/10). Try again tomorrow!',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final result = await ref
        .read(symptomClassificationServiceProvider)
        .analyzeSymptoms(_controller.text);

    if (!mounted) return;

    // Increment usage
    await usageService.incrementUsage('symptom_checker');
    ref.invalidate(todayUsageProvider('symptom_checker'));

    setState(() {
      _result = result;
      _isLoading = false;
    });

    if ((result['score'] ?? 0) > 0) {
      ref
          .read(symptomRepositoryProvider)
          .logSymptom(
            symptoms: (result['detected_symptoms'] as List? ?? [])
                .cast<String>(),
            urgencyLevel: result['urgency'],
            advisoryText: result['advisory'],
          );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Symptom Checker'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Input Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Describe your symptoms',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final usageAsync = ref.watch(
                            todayUsageProvider('symptom_checker'),
                          );
                          return usageAsync.when(
                            data: (count) => Text(
                              '$count/${UsageService.dailyLimit} used',
                              style: TextStyle(
                                fontSize: 10,
                                color: count >= UsageService.dailyLimit
                                    ? AppColors.error
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be as specific as possible (e.g. "severe headache with fever").',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'I am feeling...',
                      fillColor: Theme.of(
                        context,
                      ).inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Selection',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'Headache',
                              'Fever',
                              'Cough',
                              'Nausea',
                              'Back Pain',
                              'Fatigue',
                            ]
                            .map(
                              (s) => ActionChip(
                                label: Text(s),
                                onPressed: () {
                                  final currentText = _controller.text;
                                  _controller.text = currentText.isEmpty
                                      ? s
                                      : '$currentText, $s';
                                },
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.05,
                                ),
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Analyze Symptoms',
                    isLoading: _isLoading,
                    onPressed: _analyze,
                    icon: Icons.auto_awesome,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Result Section
            if (_result != null)
              AnimatedOpacity(
                opacity: _result != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      // Use a softer version of the color code or just primary if safe
                      color: Color(_result!['color_code']).withOpacity(0.3),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(_result!['color_code']).withOpacity(0.05),
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(_result!['color_code']).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          size: 40,
                          color: Color(_result!['color_code']),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _result!['urgency'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(_result!['color_code']),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _result!['advisory'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppColors.cardStroke),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "AI suggestions are not a medical diagnosis.",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
