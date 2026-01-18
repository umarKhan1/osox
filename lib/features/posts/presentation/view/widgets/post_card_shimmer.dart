import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                CircleAvatar(radius: 18.r, backgroundColor: baseColor),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100.w, height: 12.h, color: baseColor),
                    SizedBox(height: 4.h),
                    Container(width: 60.w, height: 10.h, color: baseColor),
                  ],
                ),
              ],
            ),
          ),

          // Media Shimmer
          AspectRatio(aspectRatio: 1, child: Container(color: baseColor)),

          // Actions Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                Container(width: 26.w, height: 26.w, color: baseColor),
                SizedBox(width: 16.w),
                Container(width: 26.w, height: 26.w, color: baseColor),
                SizedBox(width: 16.w),
                Container(width: 26.w, height: 26.w, color: baseColor),
                const Spacer(),
                Container(width: 26.w, height: 26.w, color: baseColor),
              ],
            ),
          ),

          // Content Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120.w, height: 12.h, color: baseColor),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 12.h,
                  color: baseColor,
                ),
                SizedBox(height: 4.h),
                Container(width: 200.w, height: 12.h, color: baseColor),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
