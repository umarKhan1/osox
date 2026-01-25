import 'dart:io';
import 'package:osox/features/profile/domain/models/follow_model.dart';
import 'package:osox/features/profile/domain/repositories/profile_repository.dart';
import 'package:osox/features/search/domain/models/user_search_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepository implements IProfileRepository {
  SupabaseProfileRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    // Fetch counts and relationship status in parallel
    final results = await Future.wait([
      _supabase.from('posts').select('id').eq('user_id', userId),
      _supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', userId),
      _supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId),
    ]);

    var isFollowing = false;
    var isFollower = false;

    if (currentUserId != null && currentUserId != userId) {
      final relationship = await _supabase
          .from('follows')
          .select()
          .or(
            'and(follower_id.eq.$currentUserId,following_id.eq.$userId),'
            'and(follower_id.eq.$userId,following_id.eq.$currentUserId)',
          );

      for (final rel in (relationship as List)) {
        final relMap = rel as Map<String, dynamic>;
        if (relMap['follower_id'] == currentUserId) isFollowing = true;
        if (relMap['following_id'] == currentUserId) isFollower = true;
      }
    }

    return ProfileStats(
      postsCount: (results[0] as List).length,
      followersCount: (results[1] as List).length,
      followingCount: (results[2] as List).length,
      isFollowing: isFollowing,
      isFollower: isFollower,
    );
  }

  @override
  Future<void> followUser(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('follows').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('follows').delete().match({
      'follower_id': currentUserId,
      'following_id': userId,
    });
  }

  @override
  Future<List<UserSearchResult>> getFollowers(String userId) async {
    final response = await _supabase
        .from('follows')
        .select(
          'profiles!follows_follower_id_fkey(id, full_name, email, avatar_url)',
        )
        .eq('following_id', userId);

    return (response as List).map((json) {
      final profile = json['profiles'] as Map<String, dynamic>;
      return UserSearchResult.fromJson(profile);
    }).toList();
  }

  @override
  Future<List<UserSearchResult>> getFollowing(String userId) async {
    final response = await _supabase
        .from('follows')
        .select(
          'profiles!follows_following_id_fkey'
          '(id, full_name, email, avatar_url)',
        )
        .eq('follower_id', userId);

    return (response as List).map((json) {
      // ignore: avoid_dynamic_calls
      final profile = json['profiles'] as Map<String, dynamic>;
      return UserSearchResult.fromJson(profile);
    }).toList();
  }

  @override
  Future<void> removeFollower(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('follows').delete().match({
      'follower_id': userId,
      'following_id': currentUserId,
    });
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? location,
    String? avatarPath,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    String? avatarUrl;

    if (avatarPath != null) {
      final fileExt = avatarPath.split('.').last;
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            File(avatarPath),
            fileOptions: const FileOptions(upsert: true),
          );

      avatarUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await _supabase.from('profiles').update(updates).eq('id', user.id);
    }
  }
}
