import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/habit_tracker/data/repositories/habit_repository.dart';
import '../../features/symptom_checker/data/repositories/symptom_repository.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/symptom_checker/data/services/symptom_classification_service.dart';
import '../../features/dashboard/data/personalized_insights_service.dart';
import '../../features/chat/data/services/chat_service.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/reminders/data/repositories/reminder_repository.dart';
import 'ai_service.dart';
import 'notification_service.dart';
import '../../features/usage/data/services/usage_service.dart';
import '../../features/chat/data/services/chat_storage_service.dart';
import '../constants/app_constants.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<SymptomRepository>(
    () => SymptomRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<SymptomClassificationService>(
    () => SymptomClassificationService(getIt<AIService>()),
  );

  getIt.registerLazySingleton<PersonalizedInsightsService>(
    () => PersonalizedInsightsService(getIt<AIService>()),
  );

  getIt.registerLazySingleton<ChatService>(
    () => ChatService(getIt<SupabaseClient>(), getIt<AIService>()),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // AI Service
  final aiService = AIService();
  aiService.initialize(AppConstants.aiApiKey);
  getIt.registerSingleton<AIService>(aiService);

  getIt.registerLazySingleton<UsageService>(
    () => UsageService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ChatStorageService>(
    () => ChatStorageService(getIt<SupabaseClient>()),
  );
}

// Global Providers
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return getIt<HabitRepository>();
});

final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  return getIt<SymptomRepository>();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return getIt<AuthService>();
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return getIt<ReminderRepository>();
});

final symptomClassificationServiceProvider =
    Provider<SymptomClassificationService>((ref) {
      return getIt<SymptomClassificationService>();
    });

final personalizedInsightsServiceProvider =
    Provider<PersonalizedInsightsService>((ref) {
      return getIt<PersonalizedInsightsService>();
    });

final chatServiceProvider = Provider<ChatService>((ref) {
  return getIt<ChatService>();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return getIt<NotificationService>();
});

final usageServiceProvider = Provider<UsageService>((ref) {
  return getIt<UsageService>();
});
