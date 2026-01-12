import 'package:equatable/equatable.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';

class PostModel extends Equatable {
  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileUrl,
    required this.mediaPaths,
    required this.caption,
    required this.createdAt,
    this.location,
    this.likes = 0,
    this.comments = 0,
  });

  final String id;
  final String userId;
  final String userName;
  final String userProfileUrl;
  final List<String> mediaPaths; // Support multiple images/videos
  final String caption;
  final LocationModel? location; // Optional
  final DateTime createdAt;
  final int likes;
  final int comments;

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
  ];
}
