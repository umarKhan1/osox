import 'package:flutter/material.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({required this.post, super.key});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
      ),
      body: SingleChildScrollView(child: PostCard(post: post)),
    );
  }
}
