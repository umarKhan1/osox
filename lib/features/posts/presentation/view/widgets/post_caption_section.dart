import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/features/posts/presentation/view/widgets/media_thumbnail_widget.dart';

class PostCaptionSection extends StatelessWidget {
  const PostCaptionSection({
    required this.media,
    required this.captionController,
    required this.onCaptionChanged,
    required this.isDark,
    super.key,
  });

  final XFile media;
  final TextEditingController captionController;
  final ValueChanged<String> onCaptionChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Thumbnail with shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: MediaThumbnailWidget(media: media),
            ),
          ),
          SizedBox(width: 16.w),
          // Caption Input
          Expanded(
            child: TextField(
              controller: captionController,
              maxLines: 5,
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
              ),
              onChanged: onCaptionChanged,
            ),
          ),
        ],
      ),
    );
  }
}
