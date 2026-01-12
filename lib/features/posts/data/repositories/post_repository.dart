import 'package:osox/features/posts/domain/models/post_model.dart';

class PostRepository {
  final List<PostModel> _posts = [];

  Future<void> createPost(PostModel post) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _posts.insert(0, post); // Add to beginning (newest first)
  }

  Future<List<PostModel>> getFeedPosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_posts);
  }
}
