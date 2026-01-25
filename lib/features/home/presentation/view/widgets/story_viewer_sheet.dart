import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/profile/presentation/view/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryViewerSheet extends StatefulWidget {
  const StoryViewerSheet({required this.story, super.key});

  final StoryModel story;

  @override
  State<StoryViewerSheet> createState() => _StoryViewerSheetState();
}

class _StoryViewerSheetState extends State<StoryViewerSheet> {
  List<UserModel> _viewers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadViewers();
  }

  Future<void> _loadViewers() async {
    final viewers = await context.read<HomeCubit>().getStoryViewers(
      widget.story.id,
    );
    if (mounted) {
      setState(() {
        _viewers = viewers;
        _isLoading = false;
      });
    }
  }

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
                  '${_viewers.length}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (widget.story.userId ==
                    Supabase.instance.client.auth.currentUser?.id)
                  IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (modalContext) => AlertDialog(
                          backgroundColor: const Color(0xFF2A2A2A),
                          title: const Text(
                            'Delete Story',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this story?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(modalContext),
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<HomeCubit>().deleteStory(
                                  widget.story.id,
                                );
                                Navigator.pop(modalContext); // Close dialog
                                Navigator.pop(
                                  context,
                                  true,
                                ); // Close sheet with true
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _viewers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.ghost,
                          size: 40.sp,
                          color: Colors.grey[700],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No views yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Share your story to get some eyes!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: _viewers.length,
                    itemBuilder: (context, index) {
                      final viewer = _viewers[index];
                      return GestureDetector(
                        onTap: () {
                          // Close the sheet first
                          Navigator.pop(context);
                          // Close the story view screen
                          Navigator.pop(context);
                          // Navigate to Profile
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ProfileScreen.route(userId: viewer.id),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: CachedNetworkImage(
                              imageUrl: viewer.profileUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
