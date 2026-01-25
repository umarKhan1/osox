import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.userProfileUrl,
    this.parentId,
    this.mediaUrl,
    this.likes = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    // Handle likes count
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

    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: profile?['full_name'] as String? ?? 'Unknown',
      userProfileUrl: profile?['avatar_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as String?,
      mediaUrl: json['media_url'] as String?,
      likes: likesCount,
      isLiked: (json['comment_likes'] as List?)?.isNotEmpty ?? false,
      replies:
          (json['replies'] as List?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final String? mediaUrl;
  final int likes;
  final bool isLiked;
  final List<CommentModel> replies;

  CommentModel copyWith({
    int? likes,
    bool? isLiked,
    List<CommentModel>? replies,
    String? mediaUrl,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      userProfileUrl: userProfileUrl,
      content: content,
      createdAt: createdAt,
      parentId: parentId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    userName,
    userProfileUrl,
    content,
    createdAt,
    parentId,
    mediaUrl,
    likes,
    isLiked,
    replies,
  ];
}
