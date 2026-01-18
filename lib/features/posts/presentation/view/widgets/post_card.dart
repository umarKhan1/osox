import 'package:flutter/material.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_actions_bar.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_content_viewer.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_header.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_media_carousel.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likesCount;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;
    _isBookmarked = widget.post.isBookmarked;
  }

  void _onLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });
    // TODO(dev): Call Cubit/Repository to persist like
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        PostHeader(
          post: widget.post,
          onOptionsTap: () {
            // Show more options sheet
          },
        ),

        // Media (Images/Videos)
        PostMediaCarousel(post: widget.post),

        // Actions Bar
        PostActionsBar(
          isLiked: _isLiked,
          isBookmarked: _isBookmarked,
          onLikeTap: _onLikeTap,
          onCommentTap: () {
            // Future feature
          },
          onShareTap: () {
            // Future feature
          },
          onBookmarkTap: () {
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
            // TODO(dev): Call Cubit/Repository to persist bookmark
          },
        ),

        // Content (Likes, Caption, Date)
        PostContentViewer(
          post: widget.post.copyWith(
            likes: _likesCount,
            isLiked: _isLiked,
            isBookmarked: _isBookmarked,
          ),
        ),
      ],
    );
  }
}
