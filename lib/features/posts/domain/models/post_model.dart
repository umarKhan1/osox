import 'package:equatable/equatable.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';

class PostModel extends Equatable {
  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.mediaPaths,
    required this.caption,
    required this.createdAt,
    this.userProfileUrl,
    this.location,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    // Handle likes count - if it's a list with count, extract it
    var likesCount = 0;
    if (json['likes_count'] != null) {
      if (json['likes_count'] is List &&
          (json['likes_count'] as List).isNotEmpty) {
        // ignore: avoid_dynamic_calls
        likesCount = (json['likes_count'] as List)[0]['count'] as int? ?? 0;
      } else if (json['likes_count'] is Map) {
        likesCount =
            (json['likes_count'] as Map<String, dynamic>)['count'] as int? ?? 0;
      }
    }

    // Handle comments count
    var commentsCount = 0;
    if (json['comments_count'] != null) {
      if (json['comments_count'] is List &&
          (json['comments_count'] as List).isNotEmpty) {
        commentsCount =
            // ignore: avoid_dynamic_calls
            (json['comments_count'] as List)[0]['count'] as int? ?? 0;
      } else if (json['comments_count'] is Map) {
        commentsCount =
            (json['comments_count'] as Map<String, dynamic>)['count'] as int? ??
            0;
      }
    }

    // Location can come from post record or profile fallback
    LocationModel? location;
    if (json['location'] != null) {
      location = LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      );
    } else if (profile?['location'] != null &&
        (profile?['location'] as String).isNotEmpty) {
      location = LocationModel(
        name: profile?['location'] as String,
        latitude: 0,
        longitude: 0,
      );
    }

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: profile?['full_name'] as String? ?? 'Unknown',
      userProfileUrl: profile?['avatar_url'] as String?,
      mediaPaths: List<String>.from(json['media_paths'] as List),
      caption: json['caption'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      location: location,
      likes: likesCount,
      comments: commentsCount,
      isLiked:
          json['is_liked'] as bool? ??
          (json['post_likes'] as List?)?.isNotEmpty ??
          false,
    );
  }

  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final List<String> mediaPaths; // Support multiple images/videos
  final String caption;
  final LocationModel? location; // Optional
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isBookmarked;

  PostModel copyWith({
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isBookmarked,
    String? caption,
    LocationModel? location,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      userName: userName,
      userProfileUrl: userProfileUrl,
      mediaPaths: mediaPaths,
      caption: caption ?? this.caption,
      createdAt: createdAt,
      location: location ?? this.location,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'media_paths': mediaPaths,
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userProfileUrl,
    mediaPaths,
    caption,
    location,
    createdAt,
    likes,
    comments,
    isLiked,
    isBookmarked,
  ];
}
