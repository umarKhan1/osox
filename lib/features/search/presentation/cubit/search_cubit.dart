import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/posts/data/repositories/post_repository.dart';
import 'package:osox/features/search/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(SearchInitial());

  final PostRepository _repository;

  Future<void> loadExploreFeed() async {
    emit(SearchLoading());
    try {
      final posts = await _repository.getFeedPosts();
      // For explore, we might want to shuffle or use a different endpoint later
      emit(SearchLoaded(posts: posts));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
