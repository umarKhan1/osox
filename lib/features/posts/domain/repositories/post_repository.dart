import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

abstract class IPostRepository {
  Future<void> createPost(PostModel post, List<String> localMediaPaths);
  Future<List<PostModel>> getFeedPosts({int limit = 20, int offset = 0});
  Future<List<PostModel>> getPostsByUserId(
    String userId, {
    int limit = 20,
    int offset = 0,
  });
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> deletePost(String postId);
  Future<void> updatePost(
    String postId,
    String caption, {
    LocationModel? location,
  });
  Stream<PostModel> get postUpdates;
  Future<void> notifyPostUpdate(String postId);
}
