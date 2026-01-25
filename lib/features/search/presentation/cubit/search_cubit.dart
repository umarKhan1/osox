import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/search/domain/repositories/search_repository.dart';
import 'package:osox/features/search/presentation/cubit/search_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._postRepository, this._searchRepository)
    : super(SearchInitial()) {
    _postSubscription = _postRepository.postUpdates.listen(_onPostUpdated);
  }

  final IPostRepository _postRepository;
  final ISearchRepository _searchRepository;
  Timer? _debounceTimer;
  StreamSubscription<PostModel>? _postSubscription;

  void _onPostUpdated(PostModel updatedPost) {
    final currentState = state;
    if (currentState is! SearchLoaded) return;

    final updatedPosts = currentState.posts.map((p) {
      return p.id == updatedPost.id ? updatedPost : p;
    }).toList();

    emit(SearchLoaded(posts: updatedPosts));
  }

  Future<void> loadExploreFeed() async {
    emit(SearchLoading());
    try {
      final posts = await _postRepository.getFeedPosts();
      emit(SearchLoaded(posts: posts));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> togglePostLike(String postId) async {
    final currentState = state;
    if (currentState is! SearchLoaded) return;

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

    emit(SearchLoaded(posts: updatedPosts));

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
      emit(SearchLoaded(posts: revertedPosts));
    }
  }

  void searchUsers(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // If query is empty, show explore feed
    if (query.trim().isEmpty) {
      loadExploreFeed();
      return;
    }

    // Debounce search by 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      emit(SearchLoading());
      try {
        final users = await _searchRepository.searchUsers(query.trim());
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final filteredUsers = users
            .where((user) => user.id != currentUserId)
            .toList();
        emit(SearchUsersLoaded(users: filteredUsers));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _postSubscription?.cancel();
    return super.close();
  }
}
