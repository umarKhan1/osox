import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/presentation/view/widgets/comments_bottom_sheet.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_actions_bar.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_content_viewer.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_header.dart';
import 'package:osox/features/posts/presentation/view/widgets/post_media_carousel.dart';
import 'package:osox/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:osox/features/search/presentation/cubit/search_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatefulWidget {
  const PostCard({required this.post, super.key});

  final PostModel post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isBookmarked = false;
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.post.isBookmarked;
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      _isLiked = widget.post.isLiked;
      _likesCount = widget.post.likes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        PostHeader(
          post: widget.post.copyWith(
            isLiked: _isLiked,
            likes: _likesCount,
            isBookmarked: _isBookmarked,
          ),
          onOptionsTap: () {
            // Show more options sheet
            _showOptionsSheet(context);
          },
        ),

        // Media (Images/Videos)
        PostMediaCarousel(post: widget.post),

        // Actions Bar
        PostActionsBar(
          isLiked: _isLiked,
          isBookmarked: _isBookmarked,
          onLikeTap: () {
            // 1. Optimistic Local Update
            setState(() {
              _isLiked = !_isLiked;
              if (_isLiked) {
                _likesCount++;
              } else {
                _likesCount--;
              }
            });

            // 2. Dynamically resolve the cubit to handle the database update
            try {
              context.read<SearchCubit>().togglePostLike(widget.post.id);
            } catch (_) {
              try {
                context.read<ProfileCubit>().togglePostLike(widget.post.id);
              } catch (_) {
                context.read<HomeCubit>().togglePostLike(widget.post.id);
              }
            }
          },
          onCommentTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CommentsBottomSheet(postId: widget.post.id),
            );
          },
          onShareTap: () {
            // Future feature
          },
          onBookmarkTap: () {
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
          },
        ),

        // Content (Likes, Caption, Date)
        PostContentViewer(
          post: widget.post.copyWith(
            isLiked: _isLiked,
            likes: _likesCount,
            isBookmarked: _isBookmarked,
          ),
        ),
      ],
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isOwner = widget.post.userId == currentUser?.id;

    if (!isOwner) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                context.push('/edit-post', extra: widget.post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Post',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Dynamically resolve the cubit to handle the delete
              try {
                context
                    .read<SearchCubit>()
                    .loadExploreFeed(); // Or specialized delete
              } catch (_) {}

              try {
                context.read<ProfileCubit>().loadProfile(
                  userId: widget.post.userId,
                );
              } catch (_) {}

              context.read<HomeCubit>().deletePost(widget.post.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
