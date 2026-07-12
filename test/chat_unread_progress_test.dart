import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/chat/chat_unread_progress.dart';

void main() {
  test('initial unread count decreases as messages become visible', () {
    final progress = ChatUnreadProgress();

    expect(progress.remaining(initialUnreadCount: 5), 5);
    expect(progress.markVisible(messageId: 10, initialUnread: true), isTrue);
    expect(progress.remaining(initialUnreadCount: 5), 4);
    expect(progress.markVisible(messageId: 11, initialUnread: true), isTrue);
    expect(progress.remaining(initialUnreadCount: 5), 3);
  });

  test('the same message is consumed only once', () {
    final progress = ChatUnreadProgress();

    progress.markVisible(messageId: 10, initialUnread: true);
    expect(progress.markVisible(messageId: 10, initialUnread: true), isFalse);
    expect(progress.remaining(initialUnreadCount: 2), 1);
  });

  test('live messages decrement without double-counting initial unread', () {
    final progress = ChatUnreadProgress();

    progress.addLiveMessage(20);
    expect(progress.remaining(initialUnreadCount: 3), 4);
    expect(progress.markVisible(messageId: 20, initialUnread: true), isTrue);
    expect(progress.remaining(initialUnreadCount: 3), 3);
  });
}
