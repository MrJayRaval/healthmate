import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/service_locator.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("Flutter Error: ${details.exception}");
  };

  try {
    // Load .env with error handling
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Error loading .env file: $e");
    }

    // Initialize Supabase if URL is present
    final supabaseUrl = AppConstants.supabaseUrl;
    final supabaseKey = AppConstants.supabaseAnonKey;

    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseKey,
          debug: false,
        );
        debugPrint("Supabase initialized successfully");
      } catch (e) {
        debugPrint("Error initializing Supabase: $e");
      }
    } else {
      debugPrint("Supabase URL/Key missing. Initialization skipped.");
    }

    setupLocator();

    // Initialize Notifications with error handling
    try {
      await getIt<NotificationService>().init();
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }
  } catch (e) {
    debugPrint("Critical initialization error: $e");
  } finally {
    runApp(const ProviderScope(child: HealthMateApp()));
  }
}

class HealthMateApp extends ConsumerWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'HealthMate AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
