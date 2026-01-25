import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

class VideoService {
  /// Generates a thumbnail for a local video file.
  static Future<String?> getThumbnail(String path) async {
    try {
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        path,
        quality: 50, // Balanced quality for speed
      );
      return thumbnailFile.path;
    } catch (e) {
      debugPrint('VideoService Thumbnail Error: $e');
      return null;
    }
  }

  /// Compresses a video file for upload.
  static Future<File?> compressVideo(String path) async {
    try {
      final mediaInfo = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        includeAudio: true,
      );
      return mediaInfo?.file;
    } catch (e) {
      debugPrint('VideoService Compression Error: $e');
      return null;
    }
  }

  static bool isVideo(String path) {
    final lowerCasePath = path.toLowerCase();
    return lowerCasePath.endsWith('.mp4') ||
        lowerCasePath.endsWith('.mov') ||
        lowerCasePath.endsWith('.avi') ||
        lowerCasePath.endsWith('.mkv');
  }

  static Future<void> cancelCompression() async {
    await VideoCompress.cancelCompression();
  }
}
