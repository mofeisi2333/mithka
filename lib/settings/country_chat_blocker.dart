import 'package:flutter/foundation.dart';

import '../notifications/notification_settings_payload.dart';
import '../tdlib/json_helpers.dart';
import '../tdlib/td_client.dart';
import 'country_message_filter.dart';

typedef CountryBlockerQuery =
    Future<Map<String, dynamic>> Function(
      Map<String, dynamic> request,
      int clientId,
    );

/// Applies the country policy to the first inbound message of a private chat.
///
/// A positive decision is remembered immediately, before any TDLib mutation,
/// so notification surfaces can synchronously suppress every message while the
/// chat is being muted, marked read, and added to the `_Blocked` folder.
class CountryChatBlocker {
  CountryChatBlocker({CountryMessageFilter? filter, CountryBlockerQuery? query})
    : _filter = filter ?? CountryMessageFilter.shared,
      _queryOverride = query;

  static final CountryChatBlocker shared = CountryChatBlocker();
  static const folderTitle = '_Blocked';

  final CountryMessageFilter _filter;
  final CountryBlockerQuery? _queryOverride;
  final Map<(int, int), bool> _decisions = <(int, int), bool>{};
  final Map<(int, int), Future<bool>> _pending = <(int, int), Future<bool>>{};

  bool suppressesChat(int chatId, int clientId) =>
      _decisions[(clientId, chatId)] ?? false;

  Future<bool> handleIncomingMessage(
    Map<String, dynamic> message, {
    required int clientId,
  }) async {
    if (!_filter.isEnabled || (message.boolean('is_outgoing') ?? false)) {
      return false;
    }
    final chatId = message.int64('chat_id');
    final messageId = message.int64('id');
    if (chatId == null || messageId == null) return false;
    final key = (clientId, chatId);
    final decided = _decisions[key];
    if (decided != null) {
      if (decided) await _markRead(chatId, messageId, clientId);
      return decided;
    }
    final pending = _pending[key];
    if (pending != null) {
      final blocked = await pending;
      if (blocked) await _markRead(chatId, messageId, clientId);
      return blocked;
    }
    final evaluation = _evaluateIncomingMessage(
      message,
      chatId: chatId,
      messageId: messageId,
      clientId: clientId,
      key: key,
    );
    _pending[key] = evaluation;
    try {
      return await evaluation;
    } finally {
      final _ = _pending.remove(key);
    }
  }

  Future<bool> _evaluateIncomingMessage(
    Map<String, dynamic> message, {
    required int chatId,
    required int messageId,
    required int clientId,
    required (int, int) key,
  }) async {
    try {
      final chat = await _query({
        '@type': 'getChat',
        'chat_id': chatId,
      }, clientId);
      final type = chat.obj('type');
      if (type?.type != 'chatTypePrivate' && type?.type != 'chatTypeSecret') {
        _decisions[key] = false;
        return false;
      }
      final userId = await _peerUserId(type, clientId);
      if (userId == null ||
          !await _isFirstInboundMessage(chatId, messageId, clientId)) {
        _decisions[key] = false;
        return false;
      }

      final user = await _query({
        '@type': 'getUser',
        'user_id': userId,
      }, clientId);
      if (!_filter.matchesUser(phoneNumber: user.str('phone_number'))) {
        _decisions[key] = false;
        return false;
      }

      final common = await _commonGroupFacts(userId, clientId);
      final content = message.obj('content');
      final exempt = _filter.shouldExempt(
        hasCommonPrivateGroup: common.hasPrivateGroup,
        commonGroupCount: common.count,
        isPlainTextWithoutLinks: _isPlainTextWithoutLinks(content),
        hasNonDefaultAvatar: user.obj('profile_photo') != null,
      );
      if (exempt) {
        _decisions[key] = false;
        return false;
      }

      _decisions[key] = true;
      await _quarantine(chatId, messageId, clientId);
      return true;
    } catch (error) {
      debugPrint('Country chat blocker evaluation failed: $error');
      return _decisions[key] ?? false;
    }
  }

  Future<bool> _isFirstInboundMessage(
    int chatId,
    int messageId,
    int clientId,
  ) async {
    final history = await _query({
      '@type': 'getChatHistory',
      'chat_id': chatId,
      'from_message_id': messageId,
      'offset': 0,
      'limit': 2,
      'only_local': false,
    }, clientId);
    final messages = history.objects('messages') ?? const [];
    return !messages.any((item) => item.int64('id') != messageId);
  }

  Future<int?> _peerUserId(Map<String, dynamic>? type, int clientId) async {
    if (type?.type == 'chatTypePrivate') return type?.int64('user_id');
    final secretChatId = type?.int64('secret_chat_id');
    if (secretChatId == null) return null;
    final secret = await _query({
      '@type': 'getSecretChat',
      'secret_chat_id': secretChatId,
    }, clientId);
    return secret.int64('user_id');
  }

  Future<_CommonGroupFacts> _commonGroupFacts(int userId, int clientId) async {
    if (!_filter.exemptCommonPrivateGroup && !_filter.exemptThreeCommonGroups) {
      return const _CommonGroupFacts();
    }
    final result = await _query({
      '@type': 'getGroupsInCommon',
      'user_id': userId,
      'offset_chat_id': 0,
      'limit': 3,
    }, clientId);
    final chatIds = result.int64Array('chat_ids') ?? const <int>[];
    if (!_filter.exemptCommonPrivateGroup || chatIds.isEmpty) {
      return _CommonGroupFacts(count: chatIds.length);
    }
    for (final chatId in chatIds) {
      if (await _isPrivateGroup(chatId, clientId)) {
        return _CommonGroupFacts(count: chatIds.length, hasPrivateGroup: true);
      }
    }
    return _CommonGroupFacts(count: chatIds.length);
  }

  Future<bool> _isPrivateGroup(int chatId, int clientId) async {
    final chat = await _query({
      '@type': 'getChat',
      'chat_id': chatId,
    }, clientId);
    final type = chat.obj('type');
    if (type?.type == 'chatTypeBasicGroup') return true;
    if (type?.type != 'chatTypeSupergroup') return false;
    final supergroupId = type?.int64('supergroup_id');
    if (supergroupId == null) return false;
    final supergroup = await _query({
      '@type': 'getSupergroup',
      'supergroup_id': supergroupId,
    }, clientId);
    if (supergroup.boolean('is_channel') ?? false) return false;
    final usernames = supergroup.obj('usernames');
    final active =
        (usernames?['active_usernames'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false);
    return active.isEmpty;
  }

  bool _isPlainTextWithoutLinks(Map<String, dynamic>? content) {
    if (content?.type != 'messageText') return false;
    final formatted = content?.obj('text');
    final text = formatted?.str('text') ?? '';
    final entities = formatted?.objects('entities') ?? const [];
    const linkedTypes = {
      'textEntityTypeUrl',
      'textEntityTypeTextUrl',
      'textEntityTypeEmailAddress',
      'textEntityTypePhoneNumber',
      'textEntityTypeMention',
      'textEntityTypeMentionName',
      'textEntityTypeHashtag',
      'textEntityTypeCashtag',
      'textEntityTypeBotCommand',
    };
    if (entities.any(
      (entity) => linkedTypes.contains(entity.obj('type')?.type),
    )) {
      return false;
    }
    return !RegExp(
      r'(?:(?:https?|tg)://|(?:www\.)|(?:t|telegram)\.me/)',
      caseSensitive: false,
    ).hasMatch(text);
  }

  Future<void> _quarantine(int chatId, int messageId, int clientId) async {
    await Future.wait([
      _query({
        '@type': 'setChatNotificationSettings',
        'chat_id': chatId,
        'notification_settings': inheritedChatNotificationSettings(
          muteFor: 2147483647,
        ),
      }, clientId),
      _markRead(chatId, messageId, clientId),
      _includeChatInBlockedFolder(chatId, clientId),
    ]);
  }

  Future<void> _markRead(int chatId, int messageId, int clientId) async {
    try {
      await _query({
        '@type': 'viewMessages',
        'chat_id': chatId,
        'message_ids': [messageId],
        'force_read': true,
      }, clientId);
    } catch (error) {
      debugPrint('Country-blocked message read sync failed: $error');
    }
  }

  Future<void> _includeChatInBlockedFolder(int chatId, int clientId) async {
    final folders = await _query({'@type': 'getChatFolders'}, clientId);
    final infos =
        folders.objects('chat_folders') ??
        folders.objects('chat_folder_infos') ??
        const <Map<String, dynamic>>[];
    Map<String, dynamic>? info;
    for (final candidate in infos) {
      if (_folderName(candidate) == folderTitle) {
        info = candidate;
        break;
      }
    }
    final folderId = info?.integer('id') ?? info?.integer('chat_folder_id');
    if (folderId == null) {
      await _query({
        '@type': 'createChatFolder',
        'folder': _folderPayload(const {}, includedChatIds: {chatId}),
      }, clientId);
      return;
    }
    final folder = await _query({
      '@type': 'getChatFolder',
      'chat_folder_id': folderId,
    }, clientId);
    final included =
        (folder.int64Array('included_chat_ids') ?? const <int>[]).toSet()
          ..add(chatId);
    await _query({
      '@type': 'editChatFolder',
      'chat_folder_id': folderId,
      'folder': _folderPayload(folder, includedChatIds: included),
    }, clientId);
  }

  Map<String, dynamic> _folderPayload(
    Map<String, dynamic> folder, {
    required Set<int> includedChatIds,
  }) {
    final existingName = folder.obj('name');
    return {
      '@type': 'chatFolder',
      'name': {
        '@type': 'chatFolderName',
        'text': {
          '@type': 'formattedText',
          'text': folderTitle,
          'entities':
              existingName?.obj('text')?.objects('entities') ?? const [],
        },
        'animate_custom_emoji':
            existingName?.boolean('animate_custom_emoji') ?? false,
      },
      if (folder.obj('icon') != null) 'icon': folder.obj('icon'),
      'color_id': folder.integer('color_id') ?? -1,
      'is_shareable': false,
      'pinned_chat_ids': folder.int64Array('pinned_chat_ids') ?? const <int>[],
      'included_chat_ids': includedChatIds.toList()..sort(),
      'excluded_chat_ids':
          folder.int64Array('excluded_chat_ids') ?? const <int>[],
      'exclude_muted': false,
      'exclude_read': false,
      'exclude_archived': false,
      'include_contacts': false,
      'include_non_contacts': false,
      'include_bots': false,
      'include_groups': false,
      'include_channels': false,
    };
  }

  String _folderName(Map<String, dynamic> folder) =>
      folder.obj('name')?.obj('text')?.str('text') ??
      folder.str('title') ??
      folder.str('name') ??
      '';

  Future<Map<String, dynamic>> _query(
    Map<String, dynamic> request,
    int clientId,
  ) {
    final override = _queryOverride;
    if (override != null) return override(request, clientId);
    final client = TdClient.shared;
    return clientId == client.activeClientId
        ? client.query(request)
        : client.queryTo(request, clientId);
  }
}

class _CommonGroupFacts {
  const _CommonGroupFacts({this.count = 0, this.hasPrivateGroup = false});

  final int count;
  final bool hasPrivateGroup;
}
