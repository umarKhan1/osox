import 'dart:io';

import 'package:osox/core/utils/video_service.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/domain/repositories/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHomeRepository implements IHomeRepository {
  SupabaseHomeRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<UserStoriesModel>> getStories() async {
    try {
      // 1. Fetch stories with user profiles joined
      // Note: We join with 'profiles' table (mapped as 'user' in our model)
      final response = await _supabase
          .from('stories')
          .select('*, profiles(*)')
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);

      // 2. Group stories by user
      final groupedStories = <String, List<StoryModel>>{};
      final users = <String, UserModel>{};

      for (final item in data) {
        final profileJson = item['profiles'] as Map<String, dynamic>;
        final user = UserModel.fromJson(profileJson);
        final story = StoryModel.fromJson(item);

        users[user.id] = user;
        groupedStories.putIfAbsent(user.id, () => []).add(story);
      }

      // 3. Convert to UserStoriesModel list
      return users.entries.map((entry) {
        return UserStoriesModel(
          user: entry.value,
          stories: groupedStories[entry.key]!,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch stories: $e');
    }
  }

  @override
  Future<void> addStory({
    required String filePath,
    required StoryType type,
    bool isLive = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var file = File(filePath);

      // Compress if it's a video
      if (VideoService.isVideo(filePath)) {
        final compressedFile = await VideoService.compressVideo(filePath);
        if (compressedFile != null) {
          file = compressedFile;
        }
      }

      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';

      // 1. Upload to Storage
      await _supabase.storage.from('stories').upload(fileName, file);

      // 2. Get Public URL
      final contentUrl = _supabase.storage
          .from('stories')
          .getPublicUrl(fileName);

      // 3. Insert into Database
      await _supabase.from('stories').insert({
        'user_id': user.id,
        'content_url': contentUrl,
        'type': type.name,
        'duration_seconds': 5, // Default or pass as parameter
        'is_live': isLive,
        'expires_at': DateTime.now()
            .toUtc()
            .add(const Duration(hours: 24))
            .toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add story: $e');
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      // 1. Get story metadata to extract file path
      final storyData = await _supabase
          .from('stories')
          .select('content_url')
          .eq('id', storyId)
          .single();

      final contentUrl = storyData['content_url'] as String;
      // ignore: avoid_print
      print('DEBUG: Extracted content_url for deletion: $contentUrl');
      const storagePrefix = 'stories/';
      if (contentUrl.contains(storagePrefix)) {
        var filePath = contentUrl.split(storagePrefix).last;

        // Strip any query parameters (like ?t=...)
        if (filePath.contains('?')) {
          filePath = filePath.split('?').first;
        }

        // ignore: avoid_print
        print('DEBUG: Attempting to delete file from storage: $filePath');

        // 3. Delete from Storage
        final removedFiles = await _supabase.storage.from('stories').remove([
          filePath,
        ]);

        // ignore: avoid_print
        print('DEBUG: Removed files count: ${removedFiles.length}');
        if (removedFiles.isEmpty) {
          // ignore: avoid_print
          print(
            'WARNING: Storage removal returned empty list. '
            'File might not have been deleted.',
          );
        }
      } else {
        // ignore: avoid_print
        print(
          // ignore: lines_longer_than_80_chars
          'WARNING: content_url does not contain storage prefix "$storagePrefix"',
        );
      }

      // 4. Delete from Database
      await _supabase.from('stories').delete().eq('id', storyId);
      // ignore: avoid_print
      print('DEBUG: Successfully deleted story from database.');
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error in deleteStory: $e');
      throw Exception('Failed to delete story: $e');
    }
  }

  @override
  Future<void> viewStory(String storyId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // ignore: avoid_print
      print('DEBUG: Attempting to mark story $storyId as viewed by ${user.id}');

      await _supabase.from('story_views').upsert({
        'story_id': storyId,
        'viewer_id': user.id,
      }, onConflict: 'story_id,viewer_id');

      // ignore: avoid_print
      print('DEBUG: Successfully marked story as viewed');
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Failed to mark story as viewed: $e');
    }
  }

  @override
  Future<List<UserModel>> getStoryViewers(String storyId) async {
    try {
      final response = await _supabase
          .from('story_views')
          .select('profiles(*)')
          .eq('story_id', storyId);

      final data = List<Map<String, dynamic>>.from(response);
      return data.map((item) {
        return UserModel.fromJson(item['profiles'] as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch viewers: $e');
    }
  }
}
