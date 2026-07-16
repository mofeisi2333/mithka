import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences extends ChangeNotifier {
  NotificationPreferences._();

  static final NotificationPreferences shared = NotificationPreferences._();

  static const _allAccountsKey = 'mithka.notifications.allAccounts.v1';
  static const _inAppSoundsKey = 'mithka.notifications.inAppSounds.v1';
  static const _inAppVibrateKey = 'mithka.notifications.inAppVibrate.v1';
  static const _inAppPreviewKey = 'mithka.notifications.inAppPreview.v1';
  static const _namesOnLockScreenKey =
      'mithka.notifications.namesOnLockScreen.v1';

  SharedPreferences? _preferences;
  bool _allAccounts = true;
  bool _inAppSounds = true;
  bool _inAppVibrate = false;
  bool _inAppPreview = true;
  bool _namesOnLockScreen = true;

  bool get allAccounts => _allAccounts;
  bool get inAppSounds => _inAppSounds;
  bool get inAppVibrate => _inAppVibrate;
  bool get inAppPreview => _inAppPreview;
  bool get namesOnLockScreen => _namesOnLockScreen;

  void initialize(SharedPreferences preferences) {
    _preferences = preferences;
    _allAccounts = preferences.getBool(_allAccountsKey) ?? true;
    _inAppSounds = preferences.getBool(_inAppSoundsKey) ?? true;
    _inAppVibrate = preferences.getBool(_inAppVibrateKey) ?? false;
    _inAppPreview = preferences.getBool(_inAppPreviewKey) ?? true;
    _namesOnLockScreen = preferences.getBool(_namesOnLockScreenKey) ?? true;
  }

  Future<void> setAllAccounts(bool value) => _set(
    value: value,
    current: _allAccounts,
    apply: () => _allAccounts = value,
    key: _allAccountsKey,
  );

  Future<void> setInAppSounds(bool value) => _set(
    value: value,
    current: _inAppSounds,
    apply: () => _inAppSounds = value,
    key: _inAppSoundsKey,
  );

  Future<void> setInAppVibrate(bool value) => _set(
    value: value,
    current: _inAppVibrate,
    apply: () => _inAppVibrate = value,
    key: _inAppVibrateKey,
  );

  Future<void> setInAppPreview(bool value) => _set(
    value: value,
    current: _inAppPreview,
    apply: () => _inAppPreview = value,
    key: _inAppPreviewKey,
  );

  Future<void> setNamesOnLockScreen(bool value) => _set(
    value: value,
    current: _namesOnLockScreen,
    apply: () => _namesOnLockScreen = value,
    key: _namesOnLockScreenKey,
  );

  Future<void> _set({
    required bool value,
    required bool current,
    required VoidCallback apply,
    required String key,
  }) async {
    if (value == current) return;
    apply();
    notifyListeners();
    await _preferences?.setBool(key, value);
  }
}
