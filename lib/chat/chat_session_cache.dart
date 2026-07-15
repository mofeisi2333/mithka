import 'dart:collection';

import '../tdlib/td_models.dart';

class ChatSessionRenderState {
  const ChatSessionRenderState({
    required this.messages,
    required this.anchoredHistory,
  });

  final List<ChatMessage> messages;
  final bool anchoredHistory;
}

/// Small in-memory LRU used to paint previously opened chats immediately.
class ChatSessionCache {
  ChatSessionCache({this.capacity = 24}) : assert(capacity > 0);

  final int capacity;
  final LinkedHashMap<int, ChatSessionRenderState> _states =
      LinkedHashMap<int, ChatSessionRenderState>();

  ChatSessionRenderState? read(int chatId) {
    final state = _states.remove(chatId);
    if (state != null) _states[chatId] = state;
    return state;
  }

  void store({
    required int chatId,
    required List<ChatMessage> messages,
    required bool anchoredHistory,
  }) {
    _states.remove(chatId);
    if (messages.isEmpty) return;
    _states[chatId] = ChatSessionRenderState(
      messages: List<ChatMessage>.unmodifiable(messages),
      anchoredHistory: anchoredHistory,
    );
    while (_states.length > capacity) {
      _states.remove(_states.keys.first);
    }
  }
}
