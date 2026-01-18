import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/home/data/repositories/home_repository.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/presentation/cubit/home_state.dart';

import 'package:osox/features/posts/data/repositories/post_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._postRepository)
    : super(const HomeInitial());

  final HomeRepository _repository;
  final PostRepository _postRepository;

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

  Future<void> addStory(StoryModel story) async {
    try {
      await _repository.addStory(story);
      await loadDashboard();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
