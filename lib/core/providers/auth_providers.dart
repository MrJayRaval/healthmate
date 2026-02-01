import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/service_locator.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState?.session != null) return authState!.session;

  try {
    return Supabase.instance.client.auth.currentSession;
  } catch (e) {
    debugPrint("SessionProvider error: $e");
    return null;
  }
});

final userProvider = Provider<User?>((ref) {
  final session = ref.watch(sessionProvider);
  return session?.user;
});
