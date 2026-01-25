import 'package:equatable/equatable.dart';

class FollowModel extends Equatable {
  const FollowModel({
    required this.followerId,
    required this.followingId,
    this.createdAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final String followerId;
  final String followingId;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [followerId, followingId, createdAt];
}

class ProfileStats extends Equatable {
  const ProfileStats({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isFollower,
  });

  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing; // Do I follow them?
  final bool isFollower; // Do they follow me?

  bool get isMutual => isFollowing && isFollower;

  @override
  List<Object?> get props => [
    postsCount,
    followersCount,
    followingCount,
    isFollowing,
    isFollower,
  ];
}
