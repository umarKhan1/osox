import 'dart:io';
import 'package:flutter/material.dart';
import 'package:osox/core/utils/video_service.dart';
import 'package:osox/features/posts/presentation/view/widgets/video_player_widget.dart';

class PostMediaWidget extends StatelessWidget {
  const PostMediaWidget({
    required this.path,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http');
    final isVideo = VideoService.isVideo(path);

    if (isVideo) {
      return VideoPlayerWidget(videoPath: path);
    }

    return isNetwork
        ? Image.network(
            path,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          )
        : Image.file(
            File(path),
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          );
  }
}
