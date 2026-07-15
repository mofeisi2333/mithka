import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/notifications/notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'notification preferences use the requested defaults and persist',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final settings = NotificationPreferences.shared;
      settings.initialize(preferences);

      expect(settings.allAccounts, isTrue);
      expect(settings.inAppSounds, isTrue);
      expect(settings.inAppVibrate, isFalse);
      expect(settings.inAppPreview, isTrue);
      expect(settings.namesOnLockScreen, isTrue);

      await settings.setAllAccounts(false);
      await settings.setInAppSounds(false);
      await settings.setInAppVibrate(true);
      await settings.setInAppPreview(false);
      await settings.setNamesOnLockScreen(false);

      settings.initialize(preferences);
      expect(settings.allAccounts, isFalse);
      expect(settings.inAppSounds, isFalse);
      expect(settings.inAppVibrate, isTrue);
      expect(settings.inAppPreview, isFalse);
      expect(settings.namesOnLockScreen, isFalse);
    },
  );
}
