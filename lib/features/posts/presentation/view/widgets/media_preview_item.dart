import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaPreviewItem extends StatelessWidget {
  const MediaPreviewItem({
    required this.asset,
    required this.isCurrentPage,
    super.key,
  });

  final AssetEntity asset;
  final bool isCurrentPage;

  @override
  Widget build(BuildContext context) {
    if (asset.type == AssetType.video) {
      return _buildVideoPreview();
    }
    return _buildImagePreview();
  }

  Widget _buildVideoPreview() {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(1000, 1000)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(snapshot.data!, fit: BoxFit.contain),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
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
