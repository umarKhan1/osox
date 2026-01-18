import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  _buildStatShimmer(),
                  _buildStatShimmer(),
                  _buildStatShimmer(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120.w, height: 16.h, color: Colors.white),
                  SizedBox(height: 8.h),
                  Container(width: 200.w, height: 14.h, color: Colors.white),
                  SizedBox(height: 4.h),
                  Container(width: 150.w, height: 14.h, color: Colors.white),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: 9,
              itemBuilder: (_, __) => Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          Container(width: 30.w, height: 16.h, color: Colors.white),
          SizedBox(height: 4.h),
          Container(width: 40.w, height: 12.h, color: Colors.white),
        ],
      ),
    );
  }
}
