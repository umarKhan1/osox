import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:osox/features/search/presentation/view/widgets/explore_tile.dart';

class ProfilePostGrid extends StatelessWidget {
  const ProfilePostGrid({required this.posts, super.key});

  final List<PostModel> posts;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = posts[index];
        return ExploreTile(
          post: post,
          index: index,
          onTap: () async {
            await context.push('/post-detail', extra: post);
            if (context.mounted) {
              context.read<ProfileCubit>().loadProfile(userId: post.userId);
            }
          },
        );
      }, childCount: posts.length),
    );
  }
}
