class ChatUnreadProgress {
  final Set<int> _seenInitialMessageIds = <int>{};
  final Set<int> _liveMessageIds = <int>{};

  int get liveCount => _liveMessageIds.length;

  int remaining({required int initialUnreadCount}) =>
      (initialUnreadCount - _seenInitialMessageIds.length).clamp(0, 1 << 30) +
      _liveMessageIds.length;

  bool addLiveMessage(int messageId) => _liveMessageIds.add(messageId);

  bool addLiveMessages(Iterable<int> messageIds) {
    var changed = false;
    for (final messageId in messageIds) {
      changed = _liveMessageIds.add(messageId) || changed;
    }
    return changed;
  }

  bool markVisible({required int messageId, required bool initialUnread}) {
    if (_liveMessageIds.remove(messageId)) return true;
    return initialUnread && _seenInitialMessageIds.add(messageId);
  }

  bool clearLiveMessages() {
    if (_liveMessageIds.isEmpty) return false;
    _liveMessageIds.clear();
    return true;
  }
}
