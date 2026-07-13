//
//  blocked_user_service.dart
//
//  Cached snapshot of Telegram blocked senders. Loaded once and kept fresh via
//  TDLib updates, so group chats can optionally hide messages from blocked users.
//

import 'package:flutter/foundation.dart';

import '../tdlib/td_client.dart';

class BlockedUserService extends ChangeNotifier {
  BlockedUserService._();
  static final BlockedUserService shared = BlockedUserService._();

  final Set<int> _blockedUserIds = {};

  /// Whether the "hide blocked user messages" feature is enabled.
  bool enabled = false;

  bool get isLoaded => _blockedUserIds.isNotEmpty || _loaded;
  bool _loaded = false;

  bool isBlocked(int senderId) => _blockedUserIds.contains(senderId);

  Future<void> loadBlockedUsers() async {
    _blockedUserIds.clear();
    _loaded = false;

    try {
      int offset = 0;
      const int limit = 200;

      while (true) {
        final result = await TdClient.shared.query({
          '@type': 'getBlockedMessageSenders',
          'block_list': {'@type': 'blockListMain'},
          'offset': offset,
          'limit': limit,
        });

        final senders = result['senders'] as List<dynamic>?;
        if (senders == null || senders.isEmpty) break;

        for (final sender in senders) {
          if (sender is Map<String, dynamic>) {
            // TDLib returns messageSender directly; accept the legacy wrapper
            // too so the cache remains compatible with stored test fixtures.
            final senderData =
                sender['sender'] as Map<String, dynamic>? ?? sender;
            if (senderData['@type'] == 'messageSenderUser') {
              final userId = senderData['user_id'];
              if (userId is int) {
                _blockedUserIds.add(userId);
              }
            }
          }
        }

        if (senders.length < limit) break;
        offset += limit;
      }
    } catch (_) {
      // Graceful: on error just leave the existing cache or empty set.
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> blockUser(int userId) async {
    if (userId <= 0 || _blockedUserIds.contains(userId)) return;
    await TdClient.shared.query({
      '@type': 'setMessageSenderBlockList',
      'sender_id': {'@type': 'messageSenderUser', 'user_id': userId},
      'block_list': {'@type': 'blockListMain'},
    });
    _blockedUserIds.add(userId);
    _loaded = true;
    notifyListeners();
  }
}
