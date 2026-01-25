import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/profile/domain/repositories/profile_repository.dart';
import 'package:osox/features/profile/presentation/cubit/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._postRepository, this._profileRepository)
    : super(ProfileInitial()) {
    _postSubscription = _postRepository.postUpdates.listen(_onPostUpdated);
  }

  final IPostRepository _postRepository;
  final IProfileRepository _profileRepository;
  StreamSubscription<PostModel>? _postSubscription;

  void _onPostUpdated(PostModel updatedPost) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final updatedPosts = currentState.posts.map((p) {
      return p.id == updatedPost.id ? updatedPost : p;
    }).toList();

    emit(currentState.copyWith(posts: updatedPosts));
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    return super.close();
  }

  Future<void> loadProfile({String? userId}) async {
    final targetUserId =
        userId ?? Supabase.instance.client.auth.currentUser?.id;
    if (targetUserId == null) return;

    emit(ProfileLoading());
    try {
      // Fetch posts specifically for this user
      final posts = await _postRepository.getPostsByUserId(targetUserId);
      final stats = await _profileRepository.getProfileStats(targetUserId);

      // Fetch user profile data directly from Supabase for now since we don't
      // have a specific getProfile method
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', targetUserId)
          .single();

      // Fetch stories for this user
      final storiesResponse = await Supabase.instance.client
          .from('stories')
          .select()
          .eq('user_id', targetUserId);

      final stories = (storiesResponse as List)
          .map((json) => StoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(
        ProfileLoaded(
          userId: targetUserId,
          fullName: profileData['full_name'] as String? ?? 'User',
          bio: profileData['bio'] as String? ?? '',
          location: profileData['location'] as String? ?? '',
          profilePicUrl: profileData['avatar_url'] as String? ?? '',
          postsCount: stats.postsCount,
          followersCount: stats.followersCount,
          followingCount: stats.followingCount,
          isFollowing: stats.isFollowing,
          isFollower: stats.isFollower,
          stories: stories,
          posts: posts.where((p) => p.userId == targetUserId).toList(),
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> togglePostLike(String postId) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final post = currentState.posts.firstWhere((p) => p.id == postId);
    final wasLiked = post.isLiked;

    final updatedPosts = currentState.posts.map((p) {
      if (p.id == postId) {
        final newIsLiked = !wasLiked;
        return p.copyWith(
          isLiked: newIsLiked,
          likes: newIsLiked ? p.likes + 1 : p.likes - 1,
        );
      }
      return p;
    }).toList();

    emit(currentState.copyWith(posts: updatedPosts));

    try {
      if (wasLiked) {
        await _postRepository.unlikePost(postId);
      } else {
        await _postRepository.likePost(postId);
      }
    } catch (e) {
      // Revert on failure
      final revertedPosts = currentState.posts.map((p) {
        if (p.id == postId) {
          return p.copyWith(
            isLiked: wasLiked,
            likes: wasLiked ? p.likes + 1 : p.likes - 1,
          );
        }
        return p;
      }).toList();
      emit(currentState.copyWith(posts: revertedPosts));
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await _profileRepository.followUser(userId);
      await loadProfile(userId: userId);
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _profileRepository.unfollowUser(userId);
      await loadProfile(userId: userId);
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? location,
    String? avatarPath,
  }) async {
    try {
      await _profileRepository.updateProfile(
        fullName: fullName,
        bio: bio,
        location: location,
        avatarPath: avatarPath,
      );
      await loadProfile(); // Reload own profile
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
