import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostActionsBar extends StatelessWidget {
  const PostActionsBar({
    required this.isLiked,
    required this.isBookmarked,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onBookmarkTap,
    super.key,
  });

  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : null,
              size: 26.sp,
            ),
            onPressed: onLikeTap,
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, size: 24.sp),
            onPressed: onCommentTap,
          ),
          IconButton(
            icon: Icon(Icons.send_outlined, size: 24.sp),
            onPressed: onShareTap,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 26.sp,
            ),
            onPressed: onBookmarkTap,
          ),
        ],
      ),
    );
  }
}
