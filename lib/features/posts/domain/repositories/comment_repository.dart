import 'package:osox/features/posts/domain/models/comment_model.dart';

abstract class ICommentRepository {
  Future<List<CommentModel>> getComments(String postId);
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
    String? mediaUrl,
  });
  Future<void> likeComment(String commentId);
  Future<void> unlikeComment(String commentId);
  Future<void> deleteComment(String commentId);
}
