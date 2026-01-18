import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

class ExploreTile extends StatelessWidget {
  const ExploreTile({required this.post, required this.onTap, super.key});

  final PostModel post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mediaPath = post.mediaPaths.first;
    final isVideo = mediaPath.contains('mp4') || mediaPath.contains('mov');
    final isAudio =
        mediaPath.contains('mp3') ||
        mediaPath.contains('wav') ||
        mediaPath.contains('m4a');
    final isNetwork = mediaPath.startsWith('http');
    final isCarousel = post.mediaPaths.length > 1;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(mediaPath, isNetwork),
          if (isVideo)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
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

  Widget _buildMedia(String path, bool isNetwork) {
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }
}
