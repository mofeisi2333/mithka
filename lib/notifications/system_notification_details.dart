import 'package:flutter_local_notifications/flutter_local_notifications.dart';

NotificationDetails systemNotificationDetailsForChatIcon(
  String? chatIconPath, {
  bool playSound = true,
  bool showOnLockScreen = true,
}) {
  final hasChatIcon = chatIconPath != null && chatIconPath.isNotEmpty;
  return NotificationDetails(
    android: AndroidNotificationDetails(
      'messages',
      'Messages',
      channelDescription: 'Incoming Mithka messages',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      playSound: playSound,
      visibility: showOnLockScreen
          ? NotificationVisibility.private
          : NotificationVisibility.secret,
      largeIcon: hasChatIcon ? FilePathAndroidBitmap(chatIconPath) : null,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      attachments: hasChatIcon
          ? [
              DarwinNotificationAttachment(
                chatIconPath,
                identifier: 'chat-icon',
              ),
            ]
          : null,
    ),
  );
}
