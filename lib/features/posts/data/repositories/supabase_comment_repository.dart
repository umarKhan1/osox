import 'package:flutter/foundation.dart';
import 'package:osox/features/posts/domain/models/comment_model.dart';
import 'package:osox/features/posts/domain/repositories/comment_repository.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommentRepository implements ICommentRepository {
  SupabaseCommentRepository(this._supabase, this._postRepository);

  final SupabaseClient _supabase;
  final IPostRepository _postRepository;

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final user = _supabase.auth.currentUser;

      // Query comments where parent_id is null (top-level)
      // And join replies one level deep (standard for mobile feeds)
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles!comments_user_id_fkey(*),
            likes_count:comment_likes(count),
            comment_likes!left(user_id),
            replies:comments(
              *,
              profiles!comments_user_id_fkey(*),
              likes_count:comment_likes(count),
              comment_likes!left(user_id)
            )
          ''')
          .eq('post_id', postId)
          .filter('parent_id', 'is', null)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return _processCommentJson(json as Map<String, dynamic>, user?.id);
      }).toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching comments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  CommentModel _processCommentJson(
    Map<String, dynamic> json,
    String? currentUserId,
  ) {
    // Check if current user liked this comment
    final userLikes = json['comment_likes'] as List?;
    final isLiked =
        userLikes?.any(
          (like) => (like as Map<String, dynamic>)['user_id'] == currentUserId,
        ) ??
        false;

    // Update the json to have a boolean flag or filtered list for the factory
    final processedJson = Map<String, dynamic>.from(json);
    processedJson['comment_likes'] = isLiked
        ? [
            {'user_id': currentUserId},
          ]
        : <dynamic>[];

    // Process nested replies if they exist
    if (json['replies'] != null && json['replies'] is List) {
      processedJson['replies'] = (json['replies'] as List).map((reply) {
        // ignore: avoid_dynamic_calls
        final replyLikes = reply['comment_likes'] as List?;
        final isReplyLiked =
            replyLikes?.any(
              (like) =>
                  (like as Map<String, dynamic>)['user_id'] == currentUserId,
            ) ??
            false;

        final processedReply = Map<String, dynamic>.from(reply as Map);
        processedReply['comment_likes'] = isReplyLiked
            ? [
                {'user_id': currentUserId},
              ]
            : <dynamic>[];
        return processedReply;
      }).toList();
    }

    return CommentModel.fromJson(processedJson);
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
    String? mediaUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content,
            'parent_id': parentId,
            'media_url': mediaUrl,
          })
          .select('''
        *,
        profiles!comments_user_id_fkey(*),
        likes_count:comment_likes(count)
      ''')
          .single();

      final updatedComment = CommentModel.fromJson(response);

      // Trigger post update so like counts and comment counts sync everywhere
      _postRepository.notifyPostUpdate(postId);

      return updatedComment;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  @override
  Future<void> likeComment(String commentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': user.id,
      });
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  @override
  Future<void> unlikeComment(String commentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('comment_likes').delete().match({
        'comment_id': commentId,
        'user_id': user.id,
      });
    } catch (e) {
      throw Exception('Failed to unlike comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
