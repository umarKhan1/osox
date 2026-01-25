import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:osox/core/utils/video_service.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePostRepository implements IPostRepository {
  SupabasePostRepository(this._supabase);

  final SupabaseClient _supabase;
  final _postUpdateController = StreamController<PostModel>.broadcast();

  @override
  Stream<PostModel> get postUpdates => _postUpdateController.stream;

  @override
  Future<void> notifyPostUpdate(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(*),
            likes_count:post_likes(count),
            comments_count:comments(count),
            user_liked:post_likes(user_id)
          ''')
          .eq('id', postId)
          .eq('user_liked.user_id', user?.id ?? '')
          .single();

      final postJson = response;
      final userLikedList = postJson['user_liked'] as List?;
      final isLiked = userLikedList != null && userLikedList.isNotEmpty;

      final mutableJson = Map<String, dynamic>.from(postJson);
      mutableJson['is_liked'] = isLiked;

      final updatedPost = PostModel.fromJson(mutableJson);
      _postUpdateController.add(updatedPost);
    } catch (e) {
      debugPrint('DEBUG: Error notifying post update: $e');
    }
  }

  @override
  Future<void> createPost(PostModel post, List<String> localMediaPaths) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final uploadedUrls = <String>[];

      // 1. Upload media to Supabase Storage
      for (final localPath in localMediaPaths) {
        var file = File(localPath);

        // Compress if it's a video
        if (VideoService.isVideo(localPath)) {
          final compressedFile = await VideoService.compressVideo(localPath);
          if (compressedFile != null) {
            file = compressedFile;
          }
        }

        final fileExt = p.extension(file.path);
        final fileName = '${DateTime.now().microsecondsSinceEpoch}$fileExt';
        final filePath = '${user.id}/$fileName';

        await _supabase.storage.from('posts').upload(filePath, file);
        final publicUrl = _supabase.storage
            .from('posts')
            .getPublicUrl(filePath);
        uploadedUrls.add(publicUrl);
      }

      // 2. Insert post record into Database
      await _supabase.from('posts').insert({
        'user_id': user.id,
        'caption': post.caption,
        'media_paths': uploadedUrls,
        'location': post.location?.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<List<PostModel>> getFeedPosts({int limit = 20, int offset = 0}) async {
    try {
      final user = _supabase.auth.currentUser;

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(*),
            likes_count:post_likes(count),
            comments_count:comments(count),
            user_liked:post_likes(user_id)
          ''')
          .eq('user_liked.user_id', user?.id ?? '')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        final postJson = json as Map<String, dynamic>;

        // user_liked will be a list containing the user's ID if they liked it
        final userLikedList = postJson['user_liked'] as List?;
        final isLiked = userLikedList != null && userLikedList.isNotEmpty;

        final mutableJson = Map<String, dynamic>.from(postJson);
        // Clean up the JSON for the model
        mutableJson['is_liked'] = isLiked;

        return PostModel.fromJson(mutableJson);
      }).toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching feed posts: $e');
      throw Exception('Failed to fetch feed posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(*),
            likes_count:post_likes(count),
            comments_count:comments(count),
            user_liked:post_likes(user_id)
          ''')
          .eq('user_id', userId)
          .eq('user_liked.user_id', currentUser?.id ?? '')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        final postJson = json as Map<String, dynamic>;
        final userLikedList = postJson['user_liked'] as List?;
        final isLiked = userLikedList != null && userLikedList.isNotEmpty;

        final mutableJson = Map<String, dynamic>.from(postJson);
        mutableJson['is_liked'] = isLiked;

        return PostModel.fromJson(mutableJson);
      }).toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching user posts: $e');
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': user.id,
      });
      notifyPostUpdate(postId);
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('post_likes').delete().match({
        'post_id': postId,
        'user_id': user.id,
      });
      notifyPostUpdate(postId);
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      // 1. Get post metadata to delete media from storage
      final postData = await _supabase
          .from('posts')
          .select('media_paths')
          .eq('id', postId)
          .single();

      final mediaPaths = List<String>.from(postData['media_paths'] as List);

      // 2. Delete files from storage
      for (final url in mediaPaths) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        // Assuming URL format: .../storage/v1/object/public/posts/user_id/filename
        // We need: user_id/filename
        final storagePath = pathSegments
            .sublist(pathSegments.indexOf('posts') + 1)
            .join('/');
        await _supabase.storage.from('posts').remove([storagePath]);
      }

      // 3. Delete from database (cascade will handle likes and
      // comments if set up)
      await _supabase.from('posts').delete().eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<void> updatePost(
    String postId,
    String caption, {
    LocationModel? location,
  }) async {
    try {
      await _supabase
          .from('posts')
          .update({'caption': caption, 'location': location?.toJson()})
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }
}
