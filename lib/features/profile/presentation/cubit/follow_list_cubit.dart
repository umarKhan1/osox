import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/profile/domain/repositories/profile_repository.dart';
import 'package:osox/features/search/domain/models/user_search_result.dart';

abstract class FollowListState extends Equatable {
  const FollowListState();
  @override
  List<Object?> get props => [];
}

class FollowListInitial extends FollowListState {}

class FollowListLoading extends FollowListState {}

class FollowListLoaded extends FollowListState {
  const FollowListLoaded({required this.followers, required this.following});

  final List<UserSearchResult> followers;
  final List<UserSearchResult> following;

  @override
  List<Object?> get props => [followers, following];
}

class FollowListError extends FollowListState {
  const FollowListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class FollowListCubit extends Cubit<FollowListState> {
  FollowListCubit(this._profileRepository) : super(FollowListInitial());

  final IProfileRepository _profileRepository;

  Future<void> loadLists(String userId) async {
    emit(FollowListLoading());
    try {
      final results = await Future.wait([
        _profileRepository.getFollowers(userId),
        _profileRepository.getFollowing(userId),
      ]);

      emit(FollowListLoaded(followers: results[0], following: results[1]));
    } catch (e) {
      emit(FollowListError(e.toString()));
    }
  }

  Future<void> followUser(String userId, String targetUserId) async {
    try {
      await _profileRepository.followUser(targetUserId);
      await loadLists(userId);
    } catch (e) {
      emit(FollowListError(e.toString()));
    }
  }

  Future<void> unfollowUser(String userId, String targetUserId) async {
    try {
      await _profileRepository.unfollowUser(targetUserId);
      await loadLists(userId);
    } catch (e) {
      emit(FollowListError(e.toString()));
    }
  }

  Future<void> removeFollower(String userId, String targetUserId) async {
    try {
      await _profileRepository.removeFollower(targetUserId);
      await loadLists(userId);
    } catch (e) {
      emit(FollowListError(e.toString()));
    }
  }
}
