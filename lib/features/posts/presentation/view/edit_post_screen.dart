import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/constants/app_colors.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_option_tile.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({required this.post, super.key});

  final PostModel post;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _captionController;
  LocationModel? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _selectedLocation = widget.post.location;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Media + Caption Section
            _buildCaptionSection(isDark),

            // Edit Location Option
            PostOptionTile(
              icon: Icons.location_on_outlined,
              title: _selectedLocation?.name ?? 'Add Location',
              subtitle: _selectedLocation?.address,
              isDark: isDark,
              hasValue: _selectedLocation != null,
              onTap: () async {
                final result = await context.push('/location-picker');
                if (result != null && result is LocationModel && mounted) {
                  setState(() {
                    _selectedLocation = result;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionSection(bool isDark) {
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
          // Existing Media Preview (Read-only)
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
              child: Image.network(
                widget.post.mediaPaths.first,
                width: 90.w,
                height: 90.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90.w,
                  height: 90.w,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Caption Input
          Expanded(
            child: TextField(
              controller: _captionController,
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
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Edit Post',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final newCaption = _captionController.text.trim();
            context.read<HomeCubit>().editPost(
              widget.post.id,
              newCaption,
              location: _selectedLocation,
            );
            context.pop();
          },
          child: Text(
            'Done',
            style: TextStyle(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
