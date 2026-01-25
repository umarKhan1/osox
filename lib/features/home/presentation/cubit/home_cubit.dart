import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/domain/repositories/home_repository.dart';
import 'package:osox/features/home/presentation/cubit/home_state.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._postRepository)
    : super(const HomeInitial()) {
    _postSubscription = _postRepository.postUpdates.listen(_onPostUpdated);
  }

  final IHomeRepository _repository;
  final IPostRepository _postRepository;
  StreamSubscription<PostModel>? _postSubscription;

  void _onPostUpdated(PostModel updatedPost) {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

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

  Future<void> loadDashboard() async {
    emit(const HomeLoading());
    try {
      final stories = await _repository.getStories();
      final posts = await _postRepository.getFeedPosts();
      emit(HomeLoaded(stories: stories, posts: posts));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> addStory({
    required String filePath,
    required StoryType type,
    bool isLive = false,
  }) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isUploading: true));
    }

    try {
      await _repository.addStory(
        filePath: filePath,
        type: type,
        isLive: isLive,
      );
      await loadDashboard();
    } catch (e) {
      if (state is HomeLoaded) {
        emit((state as HomeLoaded).copyWith(isUploading: false));
      }
      emit(HomeError(e.toString()));
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _repository.deleteStory(storyId);
      await loadDashboard();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> markAsViewed(String storyId) async {
    try {
      await _repository.viewStory(storyId);
      // Removed loadDashboard() here as it's too heavy for every segment view
    } catch (e) {
      if (kDebugMode) {
        print('Error marking story as viewed: $e');
      }
    }
  }

  Future<List<UserModel>> getStoryViewers(String storyId) async {
    try {
      return await _repository.getStoryViewers(storyId);
    } catch (e) {
      return [];
    }
  }

  Future<void> togglePostLike(String postId) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

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

  Future<void> deletePost(String postId) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final updatedPosts = currentState.posts
        .where((p) => p.id != postId)
        .toList();
    emit(currentState.copyWith(posts: updatedPosts));

    try {
      await _postRepository.deletePost(postId);
    } catch (e) {
      // Revert or show error
      await loadDashboard();
    }
  }

  Future<void> editPost(
    String postId,
    String newCaption, {
    LocationModel? location,
  }) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    // Update local state immediately
    final updatedPosts = currentState.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(caption: newCaption, location: location);
      }
      return p;
    }).toList();
    emit(currentState.copyWith(posts: updatedPosts));

    try {
      debugPrint('Updating post in Supabase: $postId');
      await _postRepository.updatePost(postId, newCaption, location: location);
      debugPrint('Post updated successfully');
      // Reload dashboard to get the fully updated post (including location)
      await loadDashboard();
    } catch (e) {
      debugPrint('Failed to update post in Supabase: $e');
      // Revert on failure
      await loadDashboard();
    }
  }
}
