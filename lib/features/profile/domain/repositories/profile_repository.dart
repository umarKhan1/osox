import 'package:osox/features/profile/domain/models/follow_model.dart';
import 'package:osox/features/search/domain/models/user_search_result.dart';

abstract class IProfileRepository {
  Future<ProfileStats> getProfileStats(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<UserSearchResult>> getFollowers(String userId);
  Future<List<UserSearchResult>> getFollowing(String userId);
  Future<void> removeFollower(String userId);
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? location,
    String? avatarPath,
  });
}
