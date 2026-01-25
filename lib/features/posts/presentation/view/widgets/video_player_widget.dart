import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:osox/core/utils/video_service.dart';
import 'package:video_player/video_player.dart';

/// Stable video player using Chewie package
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.videoPath,
    this.autoPlay = false,
    this.showControls = true,
    this.muted = false,
    super.key,
  });

  final String videoPath;
  final bool autoPlay;
  final bool showControls;
  final bool muted;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _thumbnailPath;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    if (!widget.videoPath.startsWith('http')) {
      _loadThumbnail();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      final isNetwork = widget.videoPath.startsWith('http');

      _videoPlayerController = isNetwork
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
          : VideoPlayerController.file(File(widget.videoPath));

      await _videoPlayerController!.initialize();

      // Set volume based on muted parameter
      if (widget.muted) {
        await _videoPlayerController!.setVolume(0);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: true,
        showControls: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadThumbnail() async {
    try {
      final path = await VideoService.getThumbnail(widget.videoPath);
      if (mounted) setState(() => _thumbnailPath = path);
    } catch (_) {}
  }

  void _handleTap() {
    if (_chewieController == null || !widget.showControls) return;

    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
    } else {
      _videoPlayerController!.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _chewieController == null) {
      return ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_thumbnailPath != null)
              Image.file(File(_thumbnailPath!), fit: BoxFit.cover)
            else
              const ColoredBox(color: Colors.black),
            const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final videoWidget = ColoredBox(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Chewie(controller: _chewieController!),
          if (widget.showControls &&
              !(_videoPlayerController?.value.isPlaying ?? false))
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white54,
              size: 60,
            ),
        ],
      ),
    );

    // Only wrap with GestureDetector if showControls is true
    if (widget.showControls) {
      return GestureDetector(onTap: _handleTap, child: videoWidget);
    }

    return videoWidget;
  }
}
