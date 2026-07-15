import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/notifications/notification_settings_payload.dart';

void main() {
  test('scope payload uses the current TDLib story-poster field', () {
    final payload = scopeNotificationSettingsPayload({
      'show_story_sender': false,
      'sound_id': -1,
    });

    expect(payload['show_story_poster'], isFalse);
    expect(payload['sound_id'], 0);
    expect(payload, isNot(contains('show_story_sender')));
  });

  test('story notification modes preserve automatic, all, and off', () {
    expect(storyNotificationMode({}), StoryNotificationMode.topFive);
    expect(
      storyNotificationMode({
        'use_default_mute_stories': false,
        'mute_stories': false,
      }),
      StoryNotificationMode.all,
    );
    final off = withStoryNotificationMode({}, StoryNotificationMode.off);
    expect(storyNotificationMode(off), StoryNotificationMode.off);
  });

  test('reaction payload can independently disable message reactions', () {
    final payload = reactionNotificationSettingsPayload({
      'message_reaction_source': reactionSource(false),
      'story_reaction_source': reactionSource(true),
    });

    expect(
      reactionSourceEnabled(
        payload['message_reaction_source'] as Map<String, dynamic>,
      ),
      isFalse,
    );
    expect(
      reactionSourceEnabled(
        payload['story_reaction_source'] as Map<String, dynamic>,
      ),
      isTrue,
    );
    expect(
      (payload['story_reaction_source'] as Map<String, dynamic>)['@type'],
      'reactionNotificationSourceContacts',
    );
  });

  test('reaction audience distinguishes contacts from everyone', () {
    final contacts = reactionSource(true);
    final everyone = reactionSourceWithAudience(everyone: true);

    expect(reactionSourceIsEveryone(contacts), isFalse);
    expect(reactionSourceIsEveryone(everyone), isTrue);
  });

  test('mute payload keeps message previews inherited', () {
    final payload = inheritedChatNotificationSettings(muteFor: 2147483647);

    expect(payload['mute_for'], 2147483647);
    expect(payload['use_default_mute_for'], isFalse);
    expect(payload['use_default_show_preview'], isTrue);
    expect(payload['use_default_sound'], isTrue);
    expect(payload['use_default_show_story_poster'], isTrue);
  });

  test('detects the legacy partial mute payload returned by TDLib', () {
    expect(
      hasLegacyHiddenNotificationPreview({
        'use_default_mute_for': false,
        'mute_for': 0,
        'use_default_sound': false,
        'sound_id': 0,
        'use_default_show_preview': false,
        'show_preview': false,
        'use_default_mute_stories': false,
        'mute_stories': false,
        'use_default_story_sound': false,
        'story_sound_id': 0,
        'use_default_show_story_poster': false,
        'show_story_poster': false,
        'use_default_disable_pinned_message_notifications': false,
        'disable_pinned_message_notifications': false,
        'use_default_disable_mention_notifications': false,
        'disable_mention_notifications': false,
      }),
      isTrue,
    );
  });

  test('does not override an intentional preview-only preference', () {
    expect(
      hasLegacyHiddenNotificationPreview({
        'use_default_show_preview': false,
        'show_preview': false,
        'use_default_sound': true,
        'use_default_mute_stories': true,
        'use_default_story_sound': true,
        'use_default_show_story_poster': true,
        'use_default_disable_pinned_message_notifications': true,
        'use_default_disable_mention_notifications': true,
      }),
      isFalse,
    );
  });

  test('repair preserves mute while restoring inherited preview', () {
    final payload = repairedChatNotificationSettings({
      'use_default_mute_for': false,
      'mute_for': 3600,
    });

    expect(payload['use_default_mute_for'], isFalse);
    expect(payload['mute_for'], 3600);
    expect(payload['use_default_show_preview'], isTrue);
  });
}
