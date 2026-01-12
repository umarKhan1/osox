import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewItem extends StatelessWidget {
  const MediaPreviewItem({
    required this.asset,
    required this.videoController,
    required this.isCurrentPage,
    super.key,
  });

  final AssetEntity asset;
  final VideoPlayerController? videoController;
  final bool isCurrentPage;

  @override
  Widget build(BuildContext context) {
    if (asset.type == AssetType.video && videoController != null) {
      return _buildVideoPreview();
    }
    return _buildImagePreview();
  }

  Widget _buildVideoPreview() {
    if (videoController!.value.isInitialized) {
      if (isCurrentPage && !videoController!.value.isPlaying) {
        videoController!.play();
      }
      return Center(
        child: AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: VideoPlayer(videoController!),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildImagePreview() {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(1000, 1000)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: BoxFit.contain);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
