import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/core/constants/app_colors.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaGridItem extends StatelessWidget {
  const MediaGridItem({
    required this.asset,
    required this.index,
    required this.isSelected,
    required this.selectionNumber,
    required this.onTap,
    required this.isDark,
    super.key,
  });

  final AssetEntity asset;
  final int index;
  final bool isSelected;
  final int? selectionNumber;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
          // Video duration badge
          if (asset.type == AssetType.video)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 12.sp),
                    SizedBox(width: 2.w),
                    Text(
                      _formatDuration(asset.duration),
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ),
          // Selection indicator
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    : Colors.white.withValues(alpha: 0.7),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: isSelected && selectionNumber != null
                  ? Center(
                      child: Text(
                        '$selectionNumber',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
