import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osox/core/utils/video_service.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/presentation/view/widgets/video_player_widget.dart';

class ExploreTile extends StatefulWidget {
  const ExploreTile({
    required this.post,
    required this.onTap,
    required this.index,
    super.key,
  });

  final PostModel post;
  final VoidCallback onTap;
  final int index;

  @override
  State<ExploreTile> createState() => _ExploreTileState();
}

class _ExploreTileState extends State<ExploreTile> {
  @override
  Widget build(BuildContext context) {
    final mediaPath = widget.post.mediaPaths.first;
    final isVideo = VideoService.isVideo(mediaPath);
    final isAudio =
        mediaPath.contains('mp3') ||
        mediaPath.contains('wav') ||
        mediaPath.contains('m4a');
    final isNetwork = mediaPath.startsWith('http');
    final isCarousel = widget.post.mediaPaths.length > 1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(mediaPath, isNetwork, isVideo),
          if (isVideo)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          else if (isAudio)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.music_note, color: Colors.white, size: 18),
            )
          else if (isCarousel)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.collections_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedia(String path, bool isNetwork, bool isVideo) {
    // For videos (both network and local), show video player
    if (isVideo) {
      return VideoPlayerWidget(
        videoPath: path,
        autoPlay: widget.index == 0, // Autoplay first video only
        showControls: false, // No controls in grid view
        muted: true, // Mute videos in grid to prevent audio overlap
      );
    }

    // For network images
    if (isNetwork && !isVideo) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.error, color: Colors.white54),
        ),
      );
    }

    // For local image files
    return Image.file(File(path), fit: BoxFit.cover);
  }
}
