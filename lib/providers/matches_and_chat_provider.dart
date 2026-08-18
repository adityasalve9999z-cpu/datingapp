import 'dart:async';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class MatchesAndChatProvider extends ChangeNotifier {
  List<ProfileModel> _matches = [];
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoadingMatches = true;
  bool _isLoadingChats = true;
  int _unreadCount = 0;
  final Map<String, List<Map<String, dynamic>>> _cachedMessages = {};
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  List<ProfileModel> get matches => _matches;
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoadingMatches => _isLoadingMatches;
  bool get isLoadingChats => _isLoadingChats;
  int get unreadCount => _unreadCount;

  MatchesAndChatProvider() {
    loadMatches();
    loadConversations();
  }

  Future<void> loadMatches() async {
    _isLoadingMatches = true;
    notifyListeners();

    try {
      final fetched = await AppApiService.fetchMatches();
      _matches = fetched.map((m) => m['profile'] as ProfileModel).toList();
      _isLoadingMatches = false;
      notifyListeners();
    } catch (_) {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  Future<void> loadConversations() async {
    _isLoadingChats = true;
    notifyListeners();

    try {
      final fetched = await AppApiService.fetchConversations();
      _conversations = fetched;
      _unreadCount = _conversations.where((c) => (c['unreadCount'] as int? ?? 0) > 0).length;
      _isLoadingChats = false;
      notifyListeners();
    } catch (_) {
      _isLoadingChats = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getMessagesFor(String userId) {
    return _cachedMessages[userId] ?? [];
  }

  Future<void> fetchMessagesFor(String userId) async {
    try {
      final msgs = await AppApiService.fetchMessages(userId);
      _cachedMessages[userId] = msgs;
      notifyListeners();
    } catch (_) {}
  }

  void subscribeToMessages(String userId) {
    _activeSubscriptions[userId]?.cancel();
    _activeSubscriptions[userId] = AppApiService.streamMessages(userId).listen((liveMessages) {
      if (liveMessages.isNotEmpty) {
        _cachedMessages[userId] = liveMessages;
        notifyListeners();
      }
    });
  }

  Future<void> sendMessage({required String toUserId, required String text}) async {
    if (text.trim().isEmpty) return;

    final newMsg = {
      'sender': 'me',
      'text': text.trim(),
      'time': 'Just now',
    };

    if (!_cachedMessages.containsKey(toUserId)) {
      _cachedMessages[toUserId] = [];
    }
    _cachedMessages[toUserId]!.add(newMsg);
    notifyListeners();

    await AppApiService.sendMessage(toUserId: toUserId, text: text.trim());
  }

  @override
  void dispose() {
    for (var sub in _activeSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
