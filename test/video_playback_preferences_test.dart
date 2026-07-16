import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/chat/video_playback_preferences.dart';
import 'package:mithka/chat/video_playback_queue.dart';
import 'package:mithka/tdlib/td_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('video playback preferences use the requested defaults', () async {
    SharedPreferences.setMockInitialValues({});

    final preferences = await VideoPlaybackPreferences.load();

    expect(
      preferences.horizontalSwipeAction,
      VideoHorizontalSwipeAction.adjustProgress,
    );
    expect(preferences.completionAction, VideoCompletionAction.prompt);
  });

  test('video playback preferences persist both custom actions', () async {
    SharedPreferences.setMockInitialValues({});

    await VideoPlaybackPreferences.saveHorizontalSwipeAction(
      VideoHorizontalSwipeAction.changeVideo,
    );
    await VideoPlaybackPreferences.saveCompletionAction(
      VideoCompletionAction.autoplayNext,
    );

    final preferences = await VideoPlaybackPreferences.load();
    expect(
      preferences.horizontalSwipeAction,
      VideoHorizontalSwipeAction.changeVideo,
    );
    expect(preferences.completionAction, VideoCompletionAction.autoplayNext);
  });

  test('unknown saved values fall back safely', () async {
    SharedPreferences.setMockInitialValues({
      VideoPlaybackPreferences.horizontalSwipePreferenceKey: 'unknown',
      VideoPlaybackPreferences.completionPreferenceKey: 'unknown',
    });

    final preferences = await VideoPlaybackPreferences.load();

    expect(
      preferences.horizontalSwipeAction,
      VideoHorizontalSwipeAction.adjustProgress,
    );
    expect(preferences.completionAction, VideoCompletionAction.prompt);
  });

  test('video playback queue moves without leaving its bounds', () {
    final queue = VideoPlaybackQueue(
      items: [
        VideoPlaybackItem(video: TdFileRef(id: 1), title: 'One'),
        VideoPlaybackItem(video: TdFileRef(id: 2), title: 'Two'),
        VideoPlaybackItem(video: TdFileRef(id: 3), title: 'Three'),
      ],
      index: 1,
    );

    expect(queue.current.video.id, 2);
    expect(queue.previous?.video.id, 1);
    expect(queue.next?.video.id, 3);
    expect(queue.moveBy(-1)?.current.video.id, 1);
    expect(queue.moveBy(1)?.current.video.id, 3);
    expect(queue.moveBy(-2), isNull);
    expect(queue.moveBy(2), isNull);
  });
}
