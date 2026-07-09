import 'dart:async';
import 'dart:io';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tdlib/td_client.dart';
import 'app_localizations.dart';

String? _tdType(Map<String, dynamic>? object) => _tdString(object, '@type');

String? _tdString(Map<String, dynamic>? object, String key) {
  final value = object?[key];
  return value is String ? value : null;
}

bool? _tdBool(Map<String, dynamic>? object, String key) {
  final value = object?[key];
  if (value is bool) return value;
  if (value is num) return value != 0;
  return null;
}

Map<String, dynamic>? _tdObject(Map<String, dynamic>? object, String key) {
  final value = object?[key];
  return value is Map<String, dynamic> ? value : null;
}

List<Map<String, dynamic>>? _tdObjects(
  Map<String, dynamic>? object,
  String key,
) {
  final value = object?[key];
  if (value is! List) return null;
  return value.whereType<Map<String, dynamic>>().toList();
}

String telegramText(
  String appFallbackKey, [
  Map<String, Object?> placeholders = const {},
]) {
  return TelegramLanguageController.shared.text(
    appFallbackKey,
    placeholders: placeholders,
  );
}

class TelegramLanguagePackOption {
  const TelegramLanguagePackOption({
    required this.id,
    required this.baseLanguagePackId,
    required this.name,
    required this.nativeName,
    required this.pluralCode,
    required this.isOfficial,
    required this.isRtl,
    required this.isBeta,
    required this.isInstalled,
  });

  factory TelegramLanguagePackOption.fromJson(Map<String, dynamic> json) {
    return TelegramLanguagePackOption(
      id: _tdString(json, 'id') ?? '',
      baseLanguagePackId: _tdString(json, 'base_language_pack_id') ?? '',
      name: _tdString(json, 'name') ?? '',
      nativeName: _tdString(json, 'native_name') ?? '',
      pluralCode: _tdString(json, 'plural_code') ?? '',
      isOfficial: _tdBool(json, 'is_official') ?? false,
      isRtl: _tdBool(json, 'is_rtl') ?? false,
      isBeta: _tdBool(json, 'is_beta') ?? false,
      isInstalled: _tdBool(json, 'is_installed') ?? false,
    );
  }

  final String id;
  final String baseLanguagePackId;
  final String name;
  final String nativeName;
  final String pluralCode;
  final bool isOfficial;
  final bool isRtl;
  final bool isBeta;
  final bool isInstalled;

  String get displayName => nativeName.trim().isNotEmpty
      ? nativeName.trim()
      : name.trim().isNotEmpty
      ? name.trim()
      : id;
}

class TelegramLanguageController extends ChangeNotifier {
  TelegramLanguageController._();

  static final shared = TelegramLanguageController._();
  static const _selectedPackKey = 'telegram.language_pack_id';
  static const _targetOption = 'localization_target';
  static const _packOption = 'language_pack_id';
  static const _queryTimeout = Duration(seconds: 20);
  static const _retryDelays = <Duration>[
    Duration(seconds: 15),
    Duration(seconds: 45),
    Duration(minutes: 2),
  ];

  SharedPreferences? _prefs;
  Locale? _appLocale;
  bool _initialized = false;
  bool _loading = false;
  String? _selectedPackId;
  String? _activePackId;
  String? _errorText;
  bool _refreshAgain = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;
  StreamSubscription<Map<String, dynamic>>? _languageUpdates;
  List<TelegramLanguagePackOption> _packs = const [];
  final Map<String, String> _strings = {};

  bool get followsAppLanguage => _selectedPackId == null;
  bool get isLoading => _loading;
  String? get errorText => _errorText;
  String? get activePackId => _activePackId;
  List<TelegramLanguagePackOption> get packs => List.unmodifiable(_packs);

  Future<void> initialize(SharedPreferences prefs) async {
    if (_initialized) return;
    _initialized = true;
    _prefs = prefs;
    AppStrings.telegramStringResolver = resolveMappedText;
    final stored = prefs.getString(_selectedPackKey)?.trim();
    if (_legacyPackMigrations.containsKey(stored)) {
      _selectedPackId = _legacyPackMigrations[stored];
      if (_selectedPackId == null) {
        await prefs.remove(_selectedPackKey);
      } else {
        await prefs.setString(_selectedPackKey, _selectedPackId!);
      }
    } else {
      _selectedPackId = stored == null || stored.isEmpty ? null : stored;
    }
    _languageUpdates ??= TdClient.shared.subscribe().listen(_handleTdUpdate);
    await refresh();
  }

  Future<void> syncAppLocale(Locale? locale) async {
    final resolved = locale == null ? null : AppLocalizations.resolve(locale);
    if (_sameLocale(_appLocale, resolved)) return;
    _appLocale = resolved;
    if (followsAppLanguage) {
      await refresh();
    }
  }

  Future<void> setSelectedPack(String? packId) async {
    final normalized = packId?.trim();
    final next = normalized == null || normalized.isEmpty ? null : normalized;
    if (_selectedPackId == next) return;
    _selectedPackId = next;
    final prefs = _prefs;
    if (prefs != null) {
      if (next == null) {
        await prefs.remove(_selectedPackKey);
      } else {
        await prefs.setString(_selectedPackKey, next);
      }
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (!_initialized) return;
    if (_loading) {
      _refreshAgain = true;
      return;
    }
    do {
      _refreshAgain = false;
      _loading = true;
      _errorText = null;
      notifyListeners();
      try {
        await _applyLocalizationTarget();
        await _loadAvailablePacks();
        final packId = _selectedPackId ?? _packIdForLocale(_appLocale);
        await _applyPack(packId);
        await _loadStringsForPack(packId);
        _activePackId = packId;
        _retryAttempt = 0;
        _retryTimer?.cancel();
        _retryTimer = null;
      } catch (error) {
        if (error is TimeoutException) {
          _scheduleRetry();
        } else {
          _errorText = error.toString();
          if (kDebugMode) debugPrint('Telegram language pack failed: $error');
        }
      } finally {
        _loading = false;
        notifyListeners();
      }
    } while (_refreshAgain);
  }

  String text(
    String appFallbackKey, {
    Map<String, Object?> placeholders = const {},
  }) {
    return resolveMappedText(appFallbackKey, placeholders) ??
        AppStrings.tLocal(appFallbackKey, placeholders);
  }

  String? resolveMappedText(
    String appFallbackKey,
    Map<String, Object?> placeholders,
  ) {
    final telegramKey = _telegramKeyForAppKey[appFallbackKey];
    final template = telegramKey == null ? null : _strings[telegramKey];
    if (template == null || template.trim().isEmpty) return null;
    return _interpolate(template, placeholders);
  }

  String raw(String telegramKey, String fallback) {
    final value = _strings[telegramKey];
    return value == null || value.trim().isEmpty ? fallback : value;
  }

  void _handleTdUpdate(Map<String, dynamic> update) {
    if (_tdType(update) != 'updateLanguagePackStrings') return;
    final packId = _tdString(update, 'language_pack_id');
    final activePack = _packs
        .where((pack) => pack.id == _activePackId)
        .firstOrNull;
    final isActivePack =
        packId == _activePackId ||
        (activePack?.baseLanguagePackId.isNotEmpty == true &&
            packId == activePack?.baseLanguagePackId);
    if (!isActivePack) return;

    final changed = _tdObjects(update, 'strings');
    if (changed == null || changed.isEmpty) {
      unawaited(refresh());
      return;
    }
    final allowedKeys = _telegramKeyForAppKey.values.toSet();
    var touched = false;
    for (final item in changed) {
      final key = _tdString(item, 'key');
      if (key == null || !allowedKeys.contains(key)) continue;
      final value = _languagePackStringValue(_tdObject(item, 'value'));
      if (value == null) {
        _strings.remove(key);
      } else {
        _strings[key] = value;
      }
      touched = true;
    }
    if (touched) notifyListeners();
  }

  Future<void> _applyLocalizationTarget() async {
    await _query({
      '@type': 'setOption',
      'name': _targetOption,
      'value': {'@type': 'optionValueString', 'value': _localizationTarget()},
    }).ignoreTimeout();
  }

  Future<void> _loadAvailablePacks() async {
    _packs = _knownRemotePacks;
    final response = await _query({
      '@type': 'getLocalizationTargetInfo',
      'only_local': false,
    });
    final packs =
        _tdObjects(response, 'language_packs')
            ?.map(TelegramLanguagePackOption.fromJson)
            .where((pack) => pack.id.isNotEmpty && !pack.isBeta)
            .toList() ??
        <TelegramLanguagePackOption>[];
    if (packs.isEmpty) {
      _packs = _knownRemotePacks;
      return;
    }
    packs.sort((a, b) {
      final official = (b.isOfficial ? 1 : 0) - (a.isOfficial ? 1 : 0);
      if (official != 0) return official;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    final knownIds = _knownRemotePacks.map((pack) => pack.id).toSet();
    _packs = [
      ..._knownRemotePacks,
      ...packs.where((pack) => !knownIds.contains(pack.id)),
    ];
  }

  Future<void> _applyPack(String packId) async {
    await _query({
      '@type': 'setOption',
      'name': _packOption,
      'value': {'@type': 'optionValueString', 'value': packId},
    }).ignoreTimeout();
  }

  Future<void> _loadStringsForPack(String packId) async {
    final merged = <String, String>{};
    final pack = _packs.where((pack) => pack.id == packId).firstOrNull;
    final baseId = pack?.baseLanguagePackId.trim();
    if (baseId != null && baseId.isNotEmpty) {
      merged.addAll(await _fetchPackStrings(baseId));
    }
    merged.addAll(await _fetchPackStrings(packId));
    _strings
      ..clear()
      ..addAll(merged);
  }

  Future<Map<String, String>> _fetchPackStrings(String packId) async {
    final response = await _query({
      '@type': 'getLanguagePackStrings',
      'language_pack_id': packId,
      'keys': _telegramKeyForAppKey.values.toSet().toList(),
    });
    final result = <String, String>{};
    for (final item in _tdObjects(response, 'strings') ?? const []) {
      final key = _tdString(item, 'key');
      final value = _languagePackStringValue(_tdObject(item, 'value'));
      if (key != null && value != null) result[key] = value;
    }
    return result;
  }

  Future<Map<String, dynamic>> _query(Map<String, dynamic> request) {
    return _waitForTdClient().then(
      (_) => TdClient.shared.query(request).timeout(_queryTimeout),
    );
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive == true) return;
    final index = _retryAttempt < _retryDelays.length
        ? _retryAttempt
        : _retryDelays.length - 1;
    _retryAttempt += 1;
    _retryTimer = Timer(_retryDelays[index], () {
      _retryTimer = null;
      unawaited(refresh());
    });
  }

  Future<void> _waitForTdClient() async {
    for (var attempt = 0; attempt < 40; attempt += 1) {
      if (TdClient.shared.hasActiveClient) return;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw StateError('TDLib client is not active yet');
  }

  String _packIdForLocale(Locale? locale) {
    final resolved =
        locale ?? AppLocalizations.resolve(PlatformDispatcher.instance.locale);
    final candidates = _candidatePackIds(resolved);
    for (final candidate in candidates) {
      if (_packs.any((pack) => pack.id == candidate)) return candidate;
    }
    for (final candidate in candidates) {
      final lower = candidate.toLowerCase();
      final match = _packs.where((pack) {
        return pack.id.toLowerCase() == lower ||
            pack.pluralCode.toLowerCase() == lower;
      }).firstOrNull;
      if (match != null) return match.id;
    }
    return 'en';
  }

  List<String> _candidatePackIds(Locale locale) {
    if (locale.languageCode == 'zh') {
      final traditional =
          locale.scriptCode == 'Hant' ||
          locale.countryCode == 'TW' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO';
      return traditional
          ? const ['zh-hant', 'zh-tw', 'zh-hk', 'zh']
          : const ['zh-hans', 'zh-cn', 'zh'];
    }
    return [locale.languageCode.toLowerCase()];
  }

  static String? _languagePackStringValue(Map<String, dynamic>? value) {
    switch (_tdType(value)) {
      case 'languagePackStringValueOrdinary':
        return _tdString(value, 'value');
      case 'languagePackStringValuePluralized':
        return _tdString(value, 'other_value') ??
            _tdString(value, 'many_value') ??
            _tdString(value, 'few_value') ??
            _tdString(value, 'two_value') ??
            _tdString(value, 'one_value') ??
            _tdString(value, 'zero_value');
      default:
        return null;
    }
  }

  static String _localizationTarget() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows || Platform.isLinux) return 'tdesktop';
    return 'web';
  }

  static String _interpolate(
    String template,
    Map<String, Object?> placeholders,
  ) {
    var result = template;
    placeholders.forEach((key, value) {
      final replacement = '$value';
      result = result
          .replaceAll('{$key}', replacement)
          .replaceAll('%$key%', replacement);
    });
    final value1 = placeholders['value1'];
    if (value1 != null) {
      result = result
          .replaceAll('{user}', '$value1')
          .replaceAll('{name}', '$value1')
          .replaceAll('%1\$@', '$value1')
          .replaceAll('%@', '$value1');
    }
    return result;
  }

  static bool _sameLocale(Locale? a, Locale? b) =>
      a?.languageCode == b?.languageCode &&
      a?.scriptCode == b?.scriptCode &&
      a?.countryCode == b?.countryCode;

  @override
  void dispose() {
    _retryTimer?.cancel();
    _languageUpdates?.cancel();
    super.dispose();
  }
}

extension _IgnoreTimeout<T> on Future<T> {
  Future<void> ignoreTimeout() async {
    try {
      await this;
    } on TimeoutException {
      // Language-pack options are best-effort. The app can still localize with
      // Mithka strings and retry fetching Telegram pack strings later.
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}

const _knownRemotePacks = <TelegramLanguagePackOption>[
  TelegramLanguagePackOption(
    id: 'zhhanscn-qq',
    baseLanguagePackId: 'zh-hans',
    name: 'Familiar Chinese Glossary',
    nativeName: '简体中文（熟悉术语）',
    pluralCode: 'zh',
    isOfficial: false,
    isRtl: false,
    isBeta: false,
    isInstalled: true,
  ),
];

const _legacyPackMigrations = <String?, String?>{
  'mithka-zh-hans-glossary': 'zhhanscn-qq',
  'mithka-zh-hant-glossary': null,
};

const _telegramKeyForAppKey = <String, String>{
  AppStringKeys.accentColorPickerSave: 'Save',
  AppStringKeys.addMembersDone: 'Done',
  AppStringKeys.channelsFileAttachment: 'AttachDocument',
  AppStringKeys.chatDelete: 'Delete',
  AppStringKeys.chatDeleteOptionBlockSender: 'DeleteBanUser',
  AppStringKeys.chatDeleteOptionDeleteAllFromSender: 'DeleteAllFrom',
  AppStringKeys.chatDeleteOptionReportSpam: 'DeleteReportSpam',
  AppStringKeys.chatInfoClear: 'ClearHistory',
  AppStringKeys.chatInfoClearHistory: 'ClearHistory',
  AppStringKeys.chatInfoGroupFiles: 'SharedFilesTab',
  AppStringKeys.chatInfoGroupMembers: 'Members',
  AppStringKeys.chatInfoGroupVideos: 'AttachVideo',
  AppStringKeys.chatInfoLeaveGroup: 'LeaveMegaMenu',
  AppStringKeys.chatInfoPin: 'PinToTop',
  AppStringKeys.chatInfoPinChat: 'PinToTop',
  AppStringKeys.chatInfoPinLimitReachedError: 'PinFolderLimitReached',
  AppStringKeys.chatInfoPinnedHighlights: 'PinnedMessages',
  AppStringKeys.chatInfoRemove: 'Delete',
  AppStringKeys.chatInfoSearchHistory: 'Search',
  AppStringKeys.chatJoinGroup: 'JoinGroup',
  AppStringKeys.chatListCreateChannel: 'ChannelAlertCreate2',
  AppStringKeys.chatListCreateGroup: 'NewGroup',
  AppStringKeys.chatListMarkUnread: 'MarkAsUnread',
  AppStringKeys.chatListNoChats: 'NoChats',
  AppStringKeys.chatListUnpin: 'UnpinFromTop',
  AppStringKeys.chatMessageInputPlaceholder: 'SendMessage',
  AppStringKeys.chatOnline: 'Online',
  AppStringKeys.chatOffline: 'Offline',
  AppStringKeys.chatPickerChooseChat: 'SelectChat',
  AppStringKeys.chatRequestToJoin: 'RequestToJoin',
  AppStringKeys.chatSearchMessageResultLabel: 'Message',
  AppStringKeys.chatSearchMessagePlaceholder: 'SearchMessages',
  AppStringKeys.chatSearchHistoryTitle: 'Search',
  AppStringKeys.chatSearchNoMessagesFound: 'NoResult',
  AppStringKeys.chatTodoSetSuccess: 'MessagePinnedHint',
  AppStringKeys.chatTodoUnsetSuccess: 'MessageUnpinnedHint',
  AppStringKeys.chatVideoPlaceholder: 'AttachVideo',
  AppStringKeys.composerAnimatedEmojiPreview: 'AttachGif',
  AppStringKeys.composerAudio: 'AttachMusic',
  AppStringKeys.composerCamera: 'Camera',
  AppStringKeys.composerImagePreview: 'AttachPhoto',
  AppStringKeys.composerLocationPreview: 'AttachLocation',
  AppStringKeys.composerPoll: 'Poll',
  AppStringKeys.composerSend: 'SendMessage',
  AppStringKeys.composerVideoCall: 'VideoCall',
  AppStringKeys.composerVoiceCall: 'Call',
  AppStringKeys.composerVoicePreview: 'AttachAudio',
  AppStringKeys.countryPickerCancel: 'Cancel',
  AppStringKeys.editProfileTapToSet: 'Add',
  AppStringKeys.messageActionBlock: 'ReportSpamUser',
  AppStringKeys.messageActionCopy: 'Copy',
  AppStringKeys.messageActionEdit: 'Edit',
  AppStringKeys.messageActionFavorite: 'AddToFavorites',
  AppStringKeys.messageActionForward: 'Forward',
  AppStringKeys.messageActionMultiSelect: 'Select',
  AppStringKeys.messageActionQuote: 'QuoteMessage',
  AppStringKeys.messageActionReplies: 'RepliesTitle',
  AppStringKeys.messageActionReport: 'ReportChat',
  AppStringKeys.messageActionSelectText: 'SelectText',
  AppStringKeys.messageActionSetTodo: 'PinMessage',
  AppStringKeys.messageActionSticker: 'AttachSticker',
  AppStringKeys.messageActionTranslate: 'TranslateMessage',
  AppStringKeys.messageActionUnsetTodo: 'UnpinMessage',
  AppStringKeys.messageBubbleForwardedFrom: 'ForwardedFrom',
  AppStringKeys.musicPlayerAdd: 'Add',
  AppStringKeys.musicPlayerClear: 'ClearHistory',
  AppStringKeys.musicPlayerDownload: 'Download',
  AppStringKeys.musicPlayerModeRepeatOne: 'RepeatSong',
  AppStringKeys.musicPlayerModeSequence: 'RepeatList',
  AppStringKeys.musicPlayerModeShuffle: 'ShuffleList',
  AppStringKeys.musicPlayerNextTrack: 'Next',
  AppStringKeys.musicPlayerPause: 'Pause',
  AppStringKeys.musicPlayerPlay: 'Play',
  AppStringKeys.musicPlayerRemoveFromPlaylist: 'Delete',
  AppStringKeys.pinnedMessagesEmpty: 'NoPinnedMessages',
  AppStringKeys.pinnedMessagesSentBy: 'SentBy',
  AppStringKeys.privacyBlockedUsers: 'BlockedUsers',
  AppStringKeys.privacyCurrentDevice: 'CurrentSession',
  AppStringKeys.privacyEnabled: 'Enabled',
  AppStringKeys.privacyDisabled: 'Disabled',
  AppStringKeys.privacyLastSeen: 'LastSeen',
  AppStringKeys.privacyLoggedInDevices: 'Devices',
  AppStringKeys.privacyOtherDevices: 'OtherSessions',
  AppStringKeys.privacyProfilePhoto: 'PrivacyProfilePhoto',
  AppStringKeys.privacyTwoStepVerification: 'TwoStepVerification',
  AppStringKeys.privacyUnblock: 'Unblock',
  AppStringKeys.privacyVisibilityContacts: 'LastSeenContacts',
  AppStringKeys.privacyVisibilityEveryone: 'LastSeenEverybody',
  AppStringKeys.privacyVisibilityNobody: 'LastSeenNobody',
  AppStringKeys.profileAddAccount: 'AddAccount',
  AppStringKeys.profileDetailAddFriend: 'AddContactChat',
  AppStringKeys.profileDetailBio: 'UserBio',
  AppStringKeys.profileDetailMediaFiles: 'SharedMedia',
  AppStringKeys.profileDetailMusic: 'SharedMusicTab',
  AppStringKeys.profileDetailSendMessage: 'SendMessage',
  AppStringKeys.profileLogOutAccount: 'LogOut',
  AppStringKeys.profileSettings: 'Settings',
  AppStringKeys.sharedMediaEmpty: 'NoMedia',
  AppStringKeys.sharedMediaFilterAll: 'AllMedia',
  AppStringKeys.sharedMediaFilterDownloaded: 'Downloaded',
  AppStringKeys.sharedMediaFilterNotDownloaded: 'NotDownloaded',
  AppStringKeys.sharedMediaLinks: 'SharedLinksTab',
  AppStringKeys.sharedMediaNoMatches: 'NoResult',
  AppStringKeys.sharedMediaPhotosAndVideos: 'SharedMediaTab',
  AppStringKeys.sharedMediaVideos: 'AttachVideo',
  AppStringKeys.sharedMediaVoice: 'AttachAudio',
  AppStringKeys.sharedMediaVoiceMessages: 'VoiceMessages',
  AppStringKeys.stickerViewerView: 'ViewPackPreview',
  AppStringKeys.tabChannels: 'Channel',
  AppStringKeys.tabContacts: 'Contacts',
  AppStringKeys.tabMessages: 'SearchAllChatsShort',
  AppStringKeys.topicPostContentFile: 'AttachDocument',
  AppStringKeys.topicChatAllFilter: 'All',
  AppStringKeys.topicChatAllTopics: 'Topics',
  AppStringKeys.topicChatChannelMembers: 'ChannelMembers',
  AppStringKeys.topicChatChannelMessages: 'ChannelMessages',
  AppStringKeys.topicChatChannelSettings: 'ChannelSettings',
  AppStringKeys.topicChatCommentCount: 'CommentsNoNumber',
  AppStringKeys.topicChatExpand: 'PollExpand',
  AppStringKeys.topicChatInvite: 'AddMember',
  AppStringKeys.topicChatLeave: 'LeaveMegaMenu',
  AppStringKeys.topicChatLeaveChannel: 'LeaveChannel',
  AppStringKeys.topicChatLoading: 'Loading',
  AppStringKeys.topicChatPinToggle: 'PinMessage',
  AppStringKeys.topicChatPublish: 'SendMessage',
  AppStringKeys.topicChatReplyCount: 'RepliesTitle',
  AppStringKeys.topicChatSearch: 'Search',
  AppStringKeys.topicChatShare: 'ShareFile',
  AppStringKeys.topicChatTopicTitle: 'Topics',
  AppStringKeys.topicChatUsers: 'Members',
  AppStringKeys.tdMessageAutoDeleteTimerChanged: 'AutoDeleteTimerSet',
  AppStringKeys.tdMessageAutoDeleteTimerDisabled: 'AutoDeleteTimerDisabled',
  AppStringKeys.tdMessageChecklist: 'AttachChecklist',
  AppStringKeys.tdMessageContactCard: 'AttachContact',
  AppStringKeys.tdMessageDice: 'DiceInfo2',
  AppStringKeys.tdMessageExpiredPhoto: 'AttachDestructingPhotoExpired',
  AppStringKeys.tdMessageExpiredVideo: 'AttachDestructingVideoExpired',
  AppStringKeys.tdMessageForwardedStory: 'ForwardedStory',
  AppStringKeys.tdMessageGame: 'AttachGame',
  AppStringKeys.tdMessageGift: 'ActionGift',
  AppStringKeys.tdMessageGiveaway: 'BoostingGiveaway',
  AppStringKeys.tdMessageGroupCreated: 'ActionCreateGroup',
  AppStringKeys.tdMessageGroupPhotoDeleted: 'ActionRemovedPhoto',
  AppStringKeys.tdMessageGroupPhotoUpdated: 'ActionChangedPhoto',
  AppStringKeys.tdMessageGroupVideoChatEnded: 'VoipGroupVoiceChatEnded',
  AppStringKeys.tdMessageGroupVideoChatStarted: 'VoipGroupVoiceChatStarted',
  AppStringKeys.tdMessageJoinedGroupByLink: 'ActionInviteUser',
  AppStringKeys.tdMessageMemberLeftGroup: 'ActionKickUser',
  AppStringKeys.tdMessageMessagePinned: 'ActionPinnedText',
  AppStringKeys.tdMessageMusic: 'AttachMusic',
  AppStringKeys.tdMessageNewMemberJoinedGroup: 'ActionAddUser',
  AppStringKeys.tdMessageNoAudio: 'NoAudioFiles',
  AppStringKeys.tdMessageNoFiles: 'NoSharedFiles',
  AppStringKeys.tdMessageNoLinks: 'NoSharedLinks',
  AppStringKeys.tdMessageNoMembers: 'NoMembers',
  AppStringKeys.tdMessageNoPhotoVideo: 'NoMedia',
  AppStringKeys.tdMessageNoStickers: 'NoStickers',
  AppStringKeys.tdMessageNoVoice: 'NoVoiceMessages',
  AppStringKeys.tdMessagePaidContent: 'PaidMedia',
  AppStringKeys.tdMessagePhotoVideo: 'SharedMediaTab2',
  AppStringKeys.tdMessagePoll: 'Poll',
  AppStringKeys.tdMessageProduct: 'PaymentInvoice',
  AppStringKeys.tdMessageSticker: 'AttachSticker',
  AppStringKeys.tdMessageStickerPreview: 'AttachSticker',
  AppStringKeys.tdMessageSubmission: 'ActionSuggestedPost',
  AppStringKeys.tdMessageSystemMessage: 'SystemMessage',
  AppStringKeys.tdMessageUnsupportedCurrentVersion: 'UnsupportedAttachment',
  AppStringKeys.tdMessageUserJoinedTelegram: 'NotificationContactJoined',
  AppStringKeys.tdMessageVideoCall: 'CallMessageVideoIncoming',
  AppStringKeys.tdMessageVideoMessage: 'AttachRound',
  AppStringKeys.tdMessageVoiceCall: 'CallMessageIncoming',
};
