import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
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
          onTap: () => context.push('/post-detail', extra: post),
        );
      }, childCount: posts.length),
    );
  }
}
