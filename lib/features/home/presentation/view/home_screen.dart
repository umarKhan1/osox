import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (state is HomeLoading) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => const PostCardShimmer(),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
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
          }

          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
