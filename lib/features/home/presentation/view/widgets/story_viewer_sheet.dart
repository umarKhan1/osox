import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osox/features/home/domain/models/story_model.dart';

class StoryViewerSheet extends StatelessWidget {
  const StoryViewerSheet({required this.story, super.key});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark themed sheet
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.solidEye,
                  size: 16.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(width: 8.w),
                Text(
                  '${story.viewerCount}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2A2A2A),
                        title: const Text(
                          'Delete Story',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Are you sure you want delete',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'No',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Delete logic would go here
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close sheet
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    FontAwesomeIcons.solidTrashCan,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: Colors.grey[800]),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: story.viewers.length,
              itemBuilder: (context, index) {
                final viewer = story.viewers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: CachedNetworkImage(
                      imageUrl: viewer.profileUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.person, color: Colors.grey[400]),
                    ),
                  ),
                  title: Text(
                    viewer.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
