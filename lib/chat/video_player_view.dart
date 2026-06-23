//
//  video_player_view.dart
//
//  Fullscreen player for a `messageVideo`. Downloads the video file on demand
//  via TdFileCenter (showing the thumbnail + a spinner while it fetches), then
//  plays it with video_player (ExoPlayer/MDK). Tap toggles a minimal control
//  overlay: play/pause, a scrubber, the elapsed/total time and a close button.
//

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../components/photo_avatar.dart';
import '../components/sf_symbols.dart';
import '../components/toast.dart';
import '../tdlib/td_image_loader.dart';
import '../tdlib/td_models.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.video,
    this.thumb,
    this.width,
    this.height,
  });

  final TdFileRef video;
  final TdFileRef? thumb;
  final int? width;
  final int? height;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final path = await TdFileCenter.shared.path(widget.video.id);
    if (!mounted) return;
    if (path == null) {
      setState(() => _failed = true);
      showToast(context, '视频加载失败');
      return;
    }
    final c = VideoPlayerController.file(File(path));
    try {
      await c.initialize();
      await c.setLooping(false);
      await c.play();
    } catch (_) {
      await c.dispose();
      if (mounted) {
        setState(() => _failed = true);
        showToast(context, '视频无法播放');
      }
      return;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    c.addListener(_onTick);
    setState(() => _controller = c);
    _scheduleHide();
  }

  // Rebuild for play/pause + scrubber position changes.
  void _onTick() {
    if (mounted) setState(() {});
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _controlsVisible = true;
        _hideTimer?.cancel();
      } else {
        // Restart from the beginning if it finished.
        if (c.value.position >= c.value.duration) c.seekTo(Duration.zero);
        c.play();
        _scheduleHide();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: ready ? _toggleControls : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              Center(
                child: AspectRatio(
                  aspectRatio: c.value.aspectRatio,
                  child: VideoPlayer(c),
                ),
              )
            else
              _loadingState(),
            if (ready && _controlsVisible) ..._controls(c),
            // Close button is always available.
            Positioned(
              top: MediaQuery.of(context).padding.top + 6,
              left: 4,
              child: _iconButton('chevron.left', () {
                Navigator.of(context).maybePop();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.thumb != null)
          Center(
            child: AspectRatio(
              aspectRatio:
                  (widget.width != null &&
                      widget.height != null &&
                      widget.width! > 0 &&
                      widget.height! > 0)
                  ? widget.width! / widget.height!
                  : 16 / 9,
              child: TDImage(photo: widget.thumb, fit: BoxFit.contain),
            ),
          ),
        Container(color: Colors.black.withValues(alpha: 0.35)),
        Center(
          child: _failed
              ? Text(
                  '视频加载失败',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                )
              : const CircularProgressIndicator(color: Colors.white),
        ),
      ],
    );
  }

  List<Widget> _controls(VideoPlayerController c) {
    final value = c.value;
    final playing = value.isPlaying;
    return [
      // Dim so controls stay legible over bright frames.
      Container(color: Colors.black.withValues(alpha: 0.25)),
      Center(
        child: GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(
              sfIcon(playing ? 'pause.fill' : 'play.fill'),
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
      Positioned(
        left: 12,
        right: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        child: Row(
          children: [
            Text(
              _fmt(value.position),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: VideoProgressIndicator(
                c,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _fmt(value.duration),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _iconButton(String icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(sfIcon(icon), color: Colors.white, size: 28),
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
