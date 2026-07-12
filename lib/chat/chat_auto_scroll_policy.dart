class ChatAutoScrollPolicy {
  factory ChatAutoScrollPolicy({bool preserveViewport = false}) =>
      ChatAutoScrollPolicy._(preserveViewport);

  ChatAutoScrollPolicy._(this._preserveViewport);

  bool _preserveViewport;

  bool get preservesViewport => _preserveViewport;

  void noteUserScroll({
    required bool towardOlderMessages,
    required bool isAtBottom,
  }) {
    if (isAtBottom) {
      _preserveViewport = false;
    } else if (towardOlderMessages) {
      _preserveViewport = true;
    }
  }

  void returnToBottom() => _preserveViewport = false;

  bool shouldFollowAppendedMessage({required bool wasNearBottom}) =>
      !_preserveViewport && wasNearBottom;
}
