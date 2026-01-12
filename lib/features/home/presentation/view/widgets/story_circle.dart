import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/core/constants/app_strings.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:shimmer/shimmer.dart';

class StoryCircle extends StatelessWidget {
  const StoryCircle({required this.userStory, super.key, this.onTap});

  final UserStoriesModel userStory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLive = userStory.hasLiveStory;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLive ? Colors.red : Colors.grey.withValues(alpha: 0.3),
                width: 2.w,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35.r),
                child: CachedNetworkImage(
                  imageUrl: userStory.user.profileUrl,
                  width: 64.r,
                  height: 64.r,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 64.r,
                      height: 64.r,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 64.r,
                    height: 64.r,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 32.r,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLive) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Text(
                AppStrings.live,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: 4.h),
            Text(
              userStory.user.name,
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
