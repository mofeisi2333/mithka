import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/notifications/notification_target.dart';

void main() {
  group('NotificationTarget.fromLocalPayload', () {
    test('keeps TDLib chat and message identifiers', () {
      final target = NotificationTarget.fromLocalPayload(
        '{"chat_id":"-100123","message_id":"456789","title":"Group","account_slot":2}',
      );

      expect(target?.chatId, -100123);
      expect(target?.messageId, 456789);
      expect(target?.title, 'Group');
      expect(target?.accountSlot, 2);
    });

    test('rejects invalid payloads', () {
      expect(NotificationTarget.fromLocalPayload(null), isNull);
      expect(NotificationTarget.fromLocalPayload('not json'), isNull);
      expect(NotificationTarget.fromLocalPayload('{"message_id":1}'), isNull);
    });
  });

  group('NotificationTarget.fromRemoteUserInfo', () {
    test('converts private-chat and server message identifiers', () {
      final target = NotificationTarget.fromRemoteUserInfo({
        'data': {
          'user_id': '42',
          'custom': {'from_id': '123', 'msg_id': '456'},
        },
        'aps': {
          'alert': {'title': 'Alice'},
        },
      });

      expect(target?.chatId, 123);
      expect(target?.messageId, 456 << 20);
      expect(target?.accountUserId, 42);
      expect(target?.title, 'Alice');
    });

    test('converts basic-group identifiers', () {
      final target = NotificationTarget.fromRemoteUserInfo({
        'custom': {'chat_id': 321, 'msg_id': 12},
      });

      expect(target?.chatId, -321);
      expect(target?.messageId, 12 << 20);
    });

    test('converts supergroup and channel identifiers', () {
      final target = NotificationTarget.fromRemoteUserInfo({
        'data': {
          'custom': {'channel_id': 654, 'msg_id': 20},
        },
      });

      expect(target?.chatId, -1000000000654);
      expect(target?.messageId, 20 << 20);
    });

    test('converts secret-chat identifiers', () {
      final target = NotificationTarget.fromRemoteUserInfo({
        'data': {
          'custom': {'encryption_id': 77, 'msg_id': 3},
        },
      });

      expect(target?.chatId, -1999999999923);
      expect(target?.messageId, 3 << 20);
    });
  });
}
