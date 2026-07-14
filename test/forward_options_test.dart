import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/chat/forward_options.dart';

void main() {
  test('chat-level protected content blocks forwarding immediately', () async {
    final requests = <Map<String, dynamic>>[];

    await expectLater(
      assertForwardAllowed(
        query: (request) async {
          requests.add(request);
          return {'@type': 'chat', 'id': 10, 'has_protected_content': true};
        },
        fromChatId: 10,
        messageIds: const [20],
        options: const ForwardOptions(),
      ),
      throwsA(isA<ForwardBlockedException>()),
    );

    expect(requests.map((request) => request['@type']), ['getChat']);
  });

  test('message properties block regular forwards', () async {
    await expectLater(
      assertForwardAllowed(
        query: (request) async => switch (request['@type']) {
          'getChat' => {
            '@type': 'chat',
            'id': 10,
            'has_protected_content': false,
          },
          'getMessageProperties' => {
            '@type': 'messageProperties',
            'can_be_forwarded': false,
            'can_be_copied': true,
          },
          _ => throw StateError('Unexpected request: $request'),
        },
        fromChatId: 10,
        messageIds: const [20],
        options: const ForwardOptions(),
      ),
      throwsA(isA<ForwardBlockedException>()),
    );
  });

  test('send-copy paths require can_be_copied', () async {
    await expectLater(
      assertForwardAllowed(
        query: (request) async => switch (request['@type']) {
          'getChat' => {
            '@type': 'chat',
            'id': 10,
            'has_protected_content': false,
          },
          'getMessageProperties' => {
            '@type': 'messageProperties',
            'can_be_forwarded': true,
            'can_be_copied': false,
          },
          _ => throw StateError('Unexpected request: $request'),
        },
        fromChatId: 10,
        messageIds: const [20],
        options: const ForwardOptions(removeSender: true),
      ),
      throwsA(isA<ForwardBlockedException>()),
    );
  });

  test('null placeholders in a TDLib forward result are rejected', () {
    expect(
      () => assertForwardResponseComplete({
        '@type': 'messages',
        'messages': [null],
      }, 1),
      throwsA(isA<ForwardBlockedException>()),
    );
  });
}
