import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/core/constants/app_colors.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/presentation/cubit/create_post_cubit.dart';
import 'package:osox/features/posts/presentation/cubit/create_post_state.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_caption_section.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_option_tile.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({required this.selectedMedia, super.key});

  final List<XFile> selectedMedia;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<CreatePostCubit, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          // Refresh home feed before going back
          context.read<HomeCubit>().loadDashboard();
          // Go back to Home directly (skipping media selection)
          context.go('/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post shared successfully!')),
          );
        } else if (state is CreatePostError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: _buildAppBar(context, isDark),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Media + Caption Section
              PostCaptionSection(
                media: widget.selectedMedia.first,
                captionController: _captionController,
                onCaptionChanged: (value) {
                  context.read<CreatePostCubit>().updateCaption(value);
                },
                isDark: isDark,
              ),

              // Add Location Option
              BlocBuilder<CreatePostCubit, CreatePostState>(
                builder: (context, state) {
                  final location = state is CreatePostEditing
                      ? state.location
                      : null;
                  return PostOptionTile(
                    icon: Icons.location_on_outlined,
                    title: location?.name ?? 'Add Location',
                    subtitle: location?.address,
                    isDark: isDark,
                    hasValue: location != null,
                    onTap: () async {
                      final result = await context.push('/location-picker');
                      if (result != null &&
                          result is LocationModel &&
                          context.mounted) {
                        context.read<CreatePostCubit>().setLocation(result);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'New Post',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        BlocBuilder<CreatePostCubit, CreatePostState>(
          builder: (context, state) {
            if (state is CreatePostSubmitting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return TextButton(
              onPressed: state is CreatePostEditing
                  ? () {
                      // TODO(dev): Get actual user data from auth
                      context.read<CreatePostCubit>().submitPost(
                        userId: 'user_1',
                        userName: 'Current User',
                        userProfileUrl: 'https://via.placeholder.com/150',
                      );
                    }
                  : null,
              child: Text(
                'Share',
                style: TextStyle(
                  color: state is CreatePostEditing
                      ? (isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary)
                      : Colors.grey,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
