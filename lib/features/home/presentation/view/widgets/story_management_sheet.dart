import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';

class StoryManagementSheet extends StatefulWidget {
  const StoryManagementSheet({required this.story, super.key});

  final StoryModel story;

  @override
  State<StoryManagementSheet> createState() => _StoryManagementSheetState();
}

class _StoryManagementSheetState extends State<StoryManagementSheet> {
  late Future<List<UserModel>> _viewersFuture;

  @override
  void initState() {
    super.initState();
    _viewersFuture = context.read<HomeCubit>().getStoryViewers(widget.story.id);
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story?'),
        content: const Text('Are you sure you want to delete this story?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeCubit>().deleteStory(widget.story.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(
                context,
                true,
              ); // Pop sheet with 'true' to signal deletion
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Story Viewers',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: FutureBuilder<List<UserModel>>(
              future: _viewersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }

                final viewers = snapshot.data ?? [];
                if (viewers.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(40.h),
                    child: Text(
                      'No viewers yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: viewers.length,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  itemBuilder: (context, index) {
                    final viewer = viewers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: viewer.profileUrl.isNotEmpty
                            ? NetworkImage(viewer.profileUrl)
                            : null,
                        child: viewer.profileUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(viewer.name),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
