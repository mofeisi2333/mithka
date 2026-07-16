import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/notifications/system_notification_details.dart';

void main() {
  test('system notification details use the chat photo on each platform', () {
    final details = systemNotificationDetailsForChatIcon('/tmp/chat.jpg');

    final androidIcon = details.android?.largeIcon;
    expect(androidIcon, isA<FilePathAndroidBitmap>());
    expect((androidIcon as FilePathAndroidBitmap).data, '/tmp/chat.jpg');
    expect(details.iOS?.attachments, hasLength(1));
    expect(details.iOS?.attachments?.single.filePath, '/tmp/chat.jpg');
  });

  test('system notification details keep the default icon as fallback', () {
    final details = systemNotificationDetailsForChatIcon(null);

    expect(details.android?.largeIcon, isNull);
    expect(details.iOS?.attachments, isNull);
  });

  test('system notification details honor sound and lock-screen privacy', () {
    final details = systemNotificationDetailsForChatIcon(
      null,
      playSound: false,
      showOnLockScreen: false,
    );

    expect(details.android?.playSound, isFalse);
    expect(details.android?.visibility, NotificationVisibility.secret);
    expect(details.iOS?.presentSound, isFalse);
  });
}
