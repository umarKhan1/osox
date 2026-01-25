import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/home/presentation/cubit/home_state.dart';
import 'package:osox/features/home/presentation/cubit/story_view_cubit.dart';
import 'package:osox/features/home/presentation/view/story_view_screen.dart';
import 'package:osox/features/home/presentation/view/widgets/story_circle.dart';
import 'package:shimmer/shimmer.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return _buildShimmer();
        }

        if (state is HomeLoaded) {
          if (state.stories.isEmpty) return const SizedBox.shrink();

          return Container(
            height: 110.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              scrollDirection: Axis.horizontal,
              itemCount: state.stories.length,
              separatorBuilder: (context, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                return StoryCircle(
                  userStory: state.stories[index],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'story_view'),
                        builder: (context) => BlocProvider(
                          create: (context) => StoryViewCubit(),
                          child: StoryViewScreen(
                            userStory: state.stories[index],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  width: 70.r,
                  height: 70.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(width: 50.w, height: 10.h, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
