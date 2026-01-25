import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/home/presentation/cubit/home_state.dart';
import 'package:osox/features/home/presentation/view/widgets/home_header.dart';
import 'package:osox/features/home/presentation/view/widgets/stories_section.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_card.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_card_shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: const HomeHeader(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          Widget content;

          if (state is HomeLoading) {
            content = ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => const PostCardShimmer(),
            );
          } else if (state is HomeLoaded) {
            content = RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadDashboard(),
              child: ListView.builder(
                itemCount: state.posts.length + 1, // +1 for stories section
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const StoriesSection();
                  }

                  final post = state.posts[index - 1];
                  return PostCard(post: post);
                },
              ),
            );
          } else if (state is HomeError) {
            content = Center(child: Text('Error: ${state.message}'));
          } else {
            content = const SizedBox.shrink();
          }

          return Stack(
            children: [
              content,
              if (state is HomeLoaded && state.isUploading)
                Positioned(
                  bottom: 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Uploading Story...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
