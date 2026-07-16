import 'package:shared_preferences/shared_preferences.dart';

enum VideoHorizontalSwipeAction {
  disabled,
  adjustProgress,
  changeVideo,
  skipTenSeconds,
}

enum VideoCompletionAction { prompt, autoplayNext, replay, returnToChat }

class VideoPlaybackPreferences {
  const VideoPlaybackPreferences({
    this.horizontalSwipeAction = VideoHorizontalSwipeAction.adjustProgress,
    this.completionAction = VideoCompletionAction.prompt,
  });

  static const horizontalSwipePreferenceKey =
      'videoPlayback.horizontalSwipeAction';
  static const completionPreferenceKey = 'videoPlayback.completionAction';

  final VideoHorizontalSwipeAction horizontalSwipeAction;
  final VideoCompletionAction completionAction;

  static Future<VideoPlaybackPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return fromPreferences(prefs);
  }

  static VideoPlaybackPreferences fromPreferences(SharedPreferences prefs) {
    return VideoPlaybackPreferences(
      horizontalSwipeAction: _enumByName(
        VideoHorizontalSwipeAction.values,
        prefs.getString(horizontalSwipePreferenceKey),
        VideoHorizontalSwipeAction.adjustProgress,
      ),
      completionAction: _enumByName(
        VideoCompletionAction.values,
        prefs.getString(completionPreferenceKey),
        VideoCompletionAction.prompt,
      ),
    );
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  static Future<void> saveHorizontalSwipeAction(
    VideoHorizontalSwipeAction action,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(horizontalSwipePreferenceKey, action.name);
  }

  static Future<void> saveCompletionAction(VideoCompletionAction action) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(completionPreferenceKey, action.name);
  }
}
