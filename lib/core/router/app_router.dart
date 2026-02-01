import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/dashboard/presentation/home_screen.dart';
import '../../features/habit_tracker/presentation/habit_tracker_screen.dart';
import '../../features/symptom_checker/presentation/symptom_checker_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/insights_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/privacy_screen.dart';
import '../../features/profile/presentation/help_support_screen.dart';
import '../../features/reminders/presentation/reminder_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(
    authStateProvider,
  ); // Just watch to trigger refreshListenable via listener

  return GoRouter(
    initialLocation: '/',
    refreshListenable: AuthRefreshListenable(ref),
    redirect: (context, state) {
      bool isAuthenticated = false;
      try {
        final session = Supabase.instance.client.auth.currentSession;
        isAuthenticated = session != null;
      } catch (e) {
        debugPrint("Router redirect error (Supabase not initialized?): $e");
      }

      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isSplash = state.uri.toString() == '/';

      if (isSplash) return null; // Let splash handle its timer

      if (!isAuthenticated) {
        if (isLoggingIn || isSigningUp) return null;
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitTrackerScreen(),
          ),
          GoRoute(
            path: '/symptoms',
            builder: (context, state) => const SymptomCheckerScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/reminders',
            builder: (context, state) => const ReminderScreen(),
          ),
          GoRoute(
            path: '/privacy',
            builder: (context, state) => const PrivacySecurityScreen(),
          ),
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpSupportScreen(),
          ),
        ],
      ),
    ],
  );
});

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
