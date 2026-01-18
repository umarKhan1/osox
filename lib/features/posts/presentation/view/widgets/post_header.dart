import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({required this.post, required this.onOptionsTap, super.key});

  final PostModel post;
  final VoidCallback onOptionsTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(post.userProfileUrl),
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(width: 10.w),

          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (post.userId == 'user_joshua') ...[
                      SizedBox(width: 4.w),
                      Icon(Icons.verified, color: Colors.blue, size: 14.sp),
                    ],
                  ],
                ),
                if (post.location != null)
                  Text(
                    post.location!.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Options Menu
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: onOptionsTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
