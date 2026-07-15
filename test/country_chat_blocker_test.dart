import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/settings/country_chat_blocker.dart';
import 'package:mithka/settings/country_message_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<CountryMessageFilter> filterWith({
    bool exemptPlainText = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      'countryMessageFilter.selectedCountries': ['JP'],
      'countryMessageFilter.exemptCommonPrivateGroup': false,
      'countryMessageFilter.exemptThreeCommonGroups': false,
      'countryMessageFilter.exemptPlainText': exemptPlainText,
      'countryMessageFilter.exemptNonDefaultAvatar': false,
    });
    final prefs = await SharedPreferences.getInstance();
    return CountryMessageFilter()..initialize(prefs);
  }

  Map<String, dynamic> incoming({int id = 500, String text = 'hello'}) => {
    '@type': 'message',
    'id': id,
    'chat_id': 42,
    'is_outgoing': false,
    'content': {
      '@type': 'messageText',
      'text': {
        '@type': 'formattedText',
        'text': text,
        'entities': <Map<String, dynamic>>[],
      },
    },
  };

  test('quarantines the first matching inbound private message', () async {
    final requests = <Map<String, dynamic>>[];
    final blocker = CountryChatBlocker(
      filter: await filterWith(),
      query: (request, _) async {
        requests.add(request);
        return switch (request['@type']) {
          'getChat' => {
            '@type': 'chat',
            'id': 42,
            'type': {'@type': 'chatTypePrivate', 'user_id': 7},
          },
          'getChatHistory' => {
            '@type': 'messages',
            'messages': [incoming()],
          },
          'getUser' => {
            '@type': 'user',
            'id': 7,
            'phone_number': '+81 90 1234 5678',
          },
          'getChatFolders' => {
            '@type': 'chatFolders',
            'chat_folders': <Map<String, dynamic>>[],
          },
          _ => {'@type': 'ok'},
        };
      },
    );

    expect(
      await blocker.handleIncomingMessage(incoming(), clientId: 3),
      isTrue,
    );
    expect(blocker.suppressesChat(42, 3), isTrue);
    expect(
      requests.any((request) => request['@type'] == 'viewMessages'),
      isTrue,
    );
    final mute = requests.firstWhere(
      (request) => request['@type'] == 'setChatNotificationSettings',
    );
    expect(mute['notification_settings']['mute_for'], 2147483647);
    final create = requests.firstWhere(
      (request) => request['@type'] == 'createChatFolder',
    );
    expect(create['folder']['name']['text']['text'], '_Blocked');
    expect(create['folder']['included_chat_ids'], [42]);

    final mutationsBefore = requests.length;
    expect(
      await blocker.handleIncomingMessage(incoming(id: 501), clientId: 3),
      isTrue,
    );
    final laterRequests = requests.sublist(mutationsBefore);
    expect(laterRequests, hasLength(1));
    expect(laterRequests.single['@type'], 'viewMessages');
    expect(laterRequests.single['message_ids'], [501]);
  });

  test('does not quarantine an existing conversation', () async {
    final requests = <Map<String, dynamic>>[];
    final blocker = CountryChatBlocker(
      filter: await filterWith(),
      query: (request, _) async {
        requests.add(request);
        return switch (request['@type']) {
          'getChat' => {
            '@type': 'chat',
            'id': 42,
            'type': {'@type': 'chatTypePrivate', 'user_id': 7},
          },
          'getChatHistory' => {
            '@type': 'messages',
            'messages': [
              incoming(),
              {...incoming(text: 'older'), 'id': 400},
            ],
          },
          _ => {'@type': 'ok'},
        };
      },
    );

    expect(
      await blocker.handleIncomingMessage(incoming(), clientId: 3),
      isFalse,
    );
    expect(
      requests.any(
        (request) => request['@type'] == 'setChatNotificationSettings',
      ),
      isFalse,
    );
  });

  test('plain text exemption keeps the new chat visible', () async {
    final blocker = CountryChatBlocker(
      filter: await filterWith(exemptPlainText: true),
      query: (request, _) async => switch (request['@type']) {
        'getChat' => {
          '@type': 'chat',
          'id': 42,
          'type': {'@type': 'chatTypePrivate', 'user_id': 7},
        },
        'getChatHistory' => {
          '@type': 'messages',
          'messages': [incoming()],
        },
        'getUser' => {
          '@type': 'user',
          'id': 7,
          'phone_number': '+81 90 1234 5678',
        },
        _ => {'@type': 'ok'},
      },
    );

    expect(
      await blocker.handleIncomingMessage(incoming(), clientId: 3),
      isFalse,
    );
  });
}
