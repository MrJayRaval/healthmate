import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode');
    if (theme == 'light') {
      state = ThemeMode.light;
    } else if (theme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString().split('.').last);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}

final animationsProvider = NotifierProvider<AnimationsNotifier, bool>(() {
  return AnimationsNotifier();
});

class AnimationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadAnimations();
    return true; // Default to on
  }

  Future<void> _loadAnimations() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('animationsEnabled') ?? true;
  }

  Future<void> toggleAnimations() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animationsEnabled', state);
  }
}
