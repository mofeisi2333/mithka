import '../tdlib/td_models.dart';

class VideoPlaybackItem {
  const VideoPlaybackItem({
    required this.video,
    this.thumb,
    this.width,
    this.height,
    this.sourceChatId,
    this.messageId,
    this.title = '',
  });

  final TdFileRef video;
  final TdFileRef? thumb;
  final int? width;
  final int? height;
  final int? sourceChatId;
  final int? messageId;
  final String title;
}

class VideoPlaybackQueue {
  VideoPlaybackQueue({required List<VideoPlaybackItem> items, int index = 0})
    : assert(items.isNotEmpty),
      items = List<VideoPlaybackItem>.unmodifiable(items),
      index = index.clamp(0, items.length - 1);

  factory VideoPlaybackQueue.single(VideoPlaybackItem item) =>
      VideoPlaybackQueue(items: [item]);

  final List<VideoPlaybackItem> items;
  final int index;

  VideoPlaybackItem get current => items[index];
  VideoPlaybackItem? get previous => index > 0 ? items[index - 1] : null;
  VideoPlaybackItem? get next =>
      index + 1 < items.length ? items[index + 1] : null;

  VideoPlaybackQueue? moveBy(int delta) {
    final target = index + delta;
    if (target < 0 || target >= items.length) return null;
    return VideoPlaybackQueue(items: items, index: target);
  }
}
