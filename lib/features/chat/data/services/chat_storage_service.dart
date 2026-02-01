import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';

class ChatStorageService {
  final SupabaseClient _supabase;
  static const String _cachePrefix = 'chat_messages_';

  ChatStorageService(this._supabase);

  String _getCacheKey(String userId) => '$_cachePrefix$userId';

  /// Save a message to both local cache and cloud
  Future<void> saveMessage({
    required String userId,
    required String text,
    required bool isUser,
  }) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    // Save to local cache first (fast)
    await _saveToLocalCache(message);

    // Then sync to cloud (async)
    try {
      await _supabase.from('chat_messages').insert({
        'user_id': userId,
        'text': text,
        'is_user': isUser,
        'created_at': message.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Error saving to cloud: $e');
      // Message is still saved locally
    }
  }

  /// Load messages from local cache first, then sync with cloud
  Future<List<ChatMessage>> loadMessages(String userId) async {
    // Try local cache first (instant)
    final localMessages = await _loadFromLocalCache(userId);

    // Sync with cloud in background
    try {
      final cloudMessages = await _loadFromCloud(userId);

      // Update local cache with cloud data
      // We prioritize cloud data as source of truth if available
      if (cloudMessages.isNotEmpty) {
        await _updateLocalCache(userId, cloudMessages);
        return cloudMessages;
      } else if (localMessages.isNotEmpty) {
        // If cloud is empty but local is not, it might be that cloud sync failed previously
        // or user has been offline exclusively.
        // We could try to sync local to cloud here, but that's complex (duplicates).
        // For now, just return local.
      }
    } catch (e) {
      print('Error loading from cloud: $e');
    }

    // Return local cache if cloud fails or cloud is empty
    return localMessages;
  }

  /// Clear all chat history (local and cloud)
  Future<void> clearHistory(String userId) async {
    // Clear local cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getCacheKey(userId));

    // Clear cloud data
    try {
      await _supabase.from('chat_messages').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing cloud history: $e');
    }
  }

  /// Save message to local cache
  Future<void> _saveToLocalCache(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedMessages = await _loadFromLocalCache(message.userId);
    cachedMessages.add(message);

    // Keep only last 100 messages in cache
    if (cachedMessages.length > 100) {
      cachedMessages.removeRange(0, cachedMessages.length - 100);
    }

    final jsonList = cachedMessages.map((m) => m.toJson()).toList();
    await prefs.setString(_getCacheKey(message.userId), json.encode(jsonList));
  }

  /// Load messages from local cache
  Future<List<ChatMessage>> _loadFromLocalCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_getCacheKey(userId));

      if (cachedData == null) return [];

      final List<dynamic> jsonList = json.decode(cachedData);
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error loading from local cache: $e');
      return [];
    }
  }

  /// Load messages from cloud
  Future<List<ChatMessage>> _loadFromCloud(String userId) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (response as List)
        .map(
          (json) => ChatMessage(
            id: json['id'].toString(),
            userId: json['user_id'],
            text: json['text'],
            isUser: json['is_user'],
            timestamp: DateTime.parse(json['created_at']),
          ),
        )
        .toList();
  }

  /// Update local cache with cloud data
  Future<void> _updateLocalCache(
    String userId,
    List<ChatMessage> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Keep only last 100 messages
    final messagesToCache = messages.length > 100
        ? messages.sublist(messages.length - 100)
        : messages;

    final jsonList = messagesToCache.map((m) => m.toJson()).toList();
    await prefs.setString(_getCacheKey(userId), json.encode(jsonList));
  }
}
