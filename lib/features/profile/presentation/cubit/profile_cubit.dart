import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/posts/data/repositories/post_repository.dart';
import 'package:osox/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(ProfileInitial());

  final PostRepository _repository;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      // Mocking profile data for now
      final posts = await _repository.getFeedPosts();

      // Simulating a delay for the shimmer effect
      await Future<void>.delayed(const Duration(seconds: 1));

      emit(
        ProfileLoaded(
          username: 'jacob_w',
          fullName: 'Jacob West',
          bio: 'Digital goodies designer @pixsellz\nEverything is designed.',
          profilePicUrl: 'https://i.pravatar.cc/150?u=current_user',
          postsCount: posts.length,
          followersCount: 834,
          followingCount: 162,
          posts: posts,
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
