import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../data/models/chat_message.dart';
import '../data/services/chat_storage_service.dart';

final chatStorageServiceProvider = Provider<ChatStorageService>((ref) {
  return getIt<ChatStorageService>();
});

// We can keep this helper if needed, but ChatScreen manages state manually now
final chatHistoryProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  userId,
) async {
  return ref.watch(chatStorageServiceProvider).loadMessages(userId);
});
