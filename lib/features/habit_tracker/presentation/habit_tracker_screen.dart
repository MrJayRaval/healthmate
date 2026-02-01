import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/providers/habit_providers.dart';
import '../../../core/providers/settings_provider.dart';

import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class HabitTrackerScreen extends ConsumerStatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  ConsumerState<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends ConsumerState<HabitTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double _sleepHours = 8.0;
  int _waterAmount = 250;
  int _waterQuantity = 1;
  final TextEditingController _customWaterController = TextEditingController(
    text: '250',
  );
  int _stepCount = 5000;
  final int _stepGoal = 10000;
  int _selectedMoodIndex = 2;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😭', 'label': 'Very Sad', 'points': 1, 'color': Colors.blueGrey},
    {'emoji': '😔', 'label': 'Sad', 'points': 3, 'color': Colors.blue},
    {'emoji': '😐', 'label': 'Neutral', 'points': 5, 'color': Colors.amber},
    {'emoji': '🙂', 'label': 'Happy', 'points': 8, 'color': Colors.orange},
    {
      'emoji': '🤩',
      'label': 'Amazing',
      'points': 10,
      'color': Colors.pinkAccent,
    },
  ];

  final List<int> _waterPresets = [100, 250, 330, 500];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customWaterController.dispose();
    super.dispose();
  }

  void _logHabit(String type, double value, String unit) async {
    try {
      await ref
          .read(habitRepositoryProvider)
          .logHealthData(type: type, value: value, unit: unit);
      ref.invalidate(weeklyLogsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type logged successfully!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = ref.watch(animationsProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Habit Tracker',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.bed_rounded), text: 'Sleep'),
            Tab(icon: Icon(Icons.water_drop_rounded), text: 'Water'),
            Tab(icon: Icon(Icons.directions_walk_rounded), text: 'Steps'),
            Tab(icon: Icon(Icons.emoji_emotions_rounded), text: 'Mood'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AppAnimation(
            type: AnimationType.fadeInUp,
            enabled: animationsEnabled,
            child: _buildSleepTab(),
          ),
          AppAnimation(
            type: AnimationType.fadeInUp,
            enabled: animationsEnabled,
            child: _buildWaterTab(),
          ),
          AppAnimation(
            type: AnimationType.fadeInUp,
            enabled: animationsEnabled,
            child: _buildStepsTab(),
          ),
          AppAnimation(
            type: AnimationType.fadeInUp,
            enabled: animationsEnabled,
            child: _buildMoodTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeaderIcon(Icons.bed_rounded, Colors.indigo),
          const SizedBox(height: 24),
          Text(
            'How long did you sleep?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          _buildProgressCircle(
            _sleepHours / 12,
            _sleepHours.toStringAsFixed(1),
            'HOURS',
            Colors.indigo,
          ),
          const SizedBox(height: 48),
          Slider(
            value: _sleepHours,
            min: 0,
            max: 12,
            divisions: 24,
            activeColor: Colors.indigo,
            onChanged: (val) => setState(() => _sleepHours = val),
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Log Sleep',
            color: Colors.indigo,
            onPressed: () => _logHabit('sleep', _sleepHours, 'hours'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeaderIcon(Icons.water_drop_rounded, Colors.cyan),
          const SizedBox(height: 24),
          Text(
            'Hydration Tracker',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            children: _waterPresets
                .map((ml) => _buildWaterChip(ml, Colors.cyan))
                .toList(),
          ),
          const SizedBox(height: 32),
          _buildQuantityCounter(),
          const SizedBox(height: 32),
          Text(
            'Total: ${_waterAmount * _waterQuantity} ml',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Log Water',
            color: Colors.cyan,
            onPressed: () => _logHabit(
              'water',
              (_waterAmount * _waterQuantity).toDouble(),
              'ml',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    double progress = (_stepCount / _stepGoal).clamp(0.0, 1.0);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // WORLD'S BEST CREATIVE STEPS UI
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),

                Center(
                  heightFactor: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.directions_run_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_stepCount',
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'STEPS TODAY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMiniStat('Goal', '$_stepGoal'),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          _buildMiniStat(
                            'Level',
                            progress >= 1.0
                                ? 'Elite'
                                : (progress > 0.5 ? 'Active' : 'Crawler'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Progress indicator at the bottom
                Positioned(
                  bottom: 30,
                  left: 40,
                  right: 40,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_stepGoal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Adjust your progress:',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: _stepCount.toDouble(),
            min: 0,
            max: 20000,
            divisions: 100,
            activeColor: Colors.orange,
            onChanged: (val) => setState(() => _stepCount = val.toInt()),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Confirm Activity',
            color: Colors.orange,
            onPressed: () => _logHabit('steps', _stepCount.toDouble(), 'steps'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTab() {
    final selectedColor = _moods[_selectedMoodIndex]['color'] as Color;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeaderIcon(
            Icons.emoji_emotions_rounded,
            Colors.yellow.shade700,
          ),
          const SizedBox(height: 24),
          Text(
            'How are you feeling?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moods.length, (index) {
              bool selected = _selectedMoodIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedMoodIndex = index),
                child: AnimatedScale(
                  scale: selected ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _moods[index]['emoji'],
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: selectedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _moods[_selectedMoodIndex]['label'],
              style: TextStyle(
                color: selectedColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Log Mood',
            color: Colors.orangeAccent, // Yellow/Orange
            onPressed: () => _logHabit(
              'mood',
              _moods[_selectedMoodIndex]['points'].toDouble(),
              'scale',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }

  Widget _buildProgressCircle(
    double progress,
    String val,
    String unit,
    Color color,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Column(
          children: [
            Text(
              val,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              unit,
              style: const TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterChip(int ml, Color color) {
    bool sel = _waterAmount == ml;
    return ChoiceChip(
      label: Text('$ml ml'),
      selected: sel,
      onSelected: (s) => setState(() {
        _waterAmount = ml;
        _customWaterController.text = ml.toString();
      }),
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: sel ? color : Colors.grey[600],
        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildQuantityCounter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(
                  () => _waterQuantity = (_waterQuantity - 1).clamp(1, 50),
                ),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$_waterQuantity',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _waterQuantity++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
