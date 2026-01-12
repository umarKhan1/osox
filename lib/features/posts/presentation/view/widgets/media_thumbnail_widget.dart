import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class MediaThumbnailWidget extends StatelessWidget {
  const MediaThumbnailWidget({required this.media, this.size = 90, super.key});

  final XFile media;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isVideo =
        media.path.toLowerCase().endsWith('.mp4') ||
        media.path.toLowerCase().endsWith('.mov') ||
        media.path.toLowerCase().endsWith('.avi');

    if (isVideo) {
      return _buildVideoThumbnail();
    }

    return _buildImageThumbnail();
  }

  Widget _buildVideoThumbnail() {
    return Container(
      width: size.w,
      height: size.w,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.play_circle_outline, color: Colors.white, size: 40.sp),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: 12.sp),
                  SizedBox(width: 3.w),
                  Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail() {
    return Image.file(
      File(media.path),
      width: size.w,
      height: size.w,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size.w,
          height: size.w,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, size: 40.sp, color: Colors.grey[600]),
        );
      },
    );
  }
}
