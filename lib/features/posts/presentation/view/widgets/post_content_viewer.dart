import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:intl/intl.dart';

class PostContentViewer extends StatefulWidget {
  final PostModel post;

  const PostContentViewer({super.key, required this.post});

  @override
  State<PostContentViewer> createState() => _PostContentViewerState();
}

class _PostContentViewerState extends State<PostContentViewer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat('#,###');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Likes Info
          if (widget.post.likes > 0)
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Text(
                'Liked by ${formatter.format(widget.post.likes)} others',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ),

          // Caption
          if (widget.post.caption.isNotEmpty)
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13.sp,
                ),
                children: [
                  TextSpan(
                    text: '${widget.post.userName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _isExpanded
                        ? widget.post.caption
                        : _getTruncatedCaption(widget.post.caption),
                  ),
                  if (!_isExpanded && widget.post.caption.length > 80)
                    TextSpan(
                      text: ' ...more',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                    ),
                ],
              ),
            ),

          // Comments Count (Placeholder link)
          if (widget.post.comments > 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'View all ${widget.post.comments} comments',
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
              ),
            ),

          // Timestamp
          Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: 12.h),
            child: Text(
              _formatDate(widget.post.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTruncatedCaption(String caption) {
    if (caption.length <= 80) return caption;
    return caption.substring(0, 80);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMMM d').format(date).toUpperCase();
    }
  }
}
