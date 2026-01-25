import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/core/widgets/gif_picker.dart';
import 'package:osox/features/posts/domain/models/comment_model.dart';
import 'package:osox/features/posts/domain/repositories/comment_repository.dart';
import 'package:osox/features/posts/presentation/cubit/comments_cubit.dart';
import 'package:osox/features/posts/presentation/cubit/comments_state.dart';
import 'package:osox/features/profile/presentation/view/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsBottomSheet extends StatelessWidget {
  const CommentsBottomSheet({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CommentsCubit(getIt<ICommentRepository>(), postId)..loadComments(),
      child: const _CommentsView(),
    );
  }
}

class _CommentsView extends StatefulWidget {
  const _CommentsView();

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  CommentModel? _replyingTo;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onReplyTap(CommentModel comment) {
    setState(() {
      _replyingTo = comment;
      _commentController.text = '@${comment.userName} ';
    });
  }

  void _submitComment({String? mediaUrl}) {
    final content = _commentController.text.trim();
    if (content.isEmpty && mediaUrl == null) return;

    if (_replyingTo != null) {
      context.read<CommentsCubit>().addReply(
        parentId: _replyingTo!.id,
        content: content,
        mediaUrl: mediaUrl,
      );
    } else {
      context.read<CommentsCubit>().addComment(content, mediaUrl: mediaUrl);
    }

    _commentController.clear();
    _commentFocusNode.unfocus();
    setState(() {
      _replyingTo = null;
    });
  }

  Future<void> _openGifPicker() async {
    final gifUrl = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GifPickerSheet(),
    );

    if (gifUrl != null) {
      _submitComment(mediaUrl: gifUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 0.75.sh,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            height: 4.h,
            width: 40.w,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Comments',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: .1, color: Colors.grey, thickness: 0.2),

          // Comments List
          Expanded(
            child: BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommentsError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is CommentsLoaded) {
                  return Column(
                    children: [
                      if (state.errorMessage != null)
                        Container(
                          width: double.infinity,
                          color: Colors.red.withValues(alpha: 0.1),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      if (state.comments.isEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16.h),
                                    const Text(
                                      'No comments yet. '
                                      'Start the conversation!',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            itemCount: state.comments.length,
                            itemBuilder: (context, index) {
                              final comment = state.comments[index];
                              return _CommentItem(
                                comment: comment,
                                onReplyTap: _onReplyTap,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Reply Indicator
          if (_replyingTo != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.userName}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Input Area
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              top: 12.h,
              left: 16.w,
              right: 16.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji quick bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂']
                      .map((emoji) {
                        return GestureDetector(
                          onTap: () {
                            _commentController.text += emoji;
                            _commentController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _commentController.text.length,
                                  ),
                                );
                            if (!_commentFocusNode.hasFocus) {
                              _commentFocusNode.requestFocus();
                            }
                          },
                          child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
                        );
                      })
                      .toList(),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => ProfileScreen(
                              userId:
                                  Supabase.instance.client.auth.currentUser?.id,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 22.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[400]!,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.h,
                                  ),
                                ),
                                style: TextStyle(fontSize: 14.sp),
                                maxLines: null,
                              ),
                            ),
                            GestureDetector(
                              onTap: _openGifPicker,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: isDark ? Colors.white : Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'GIF',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BlocBuilder<CommentsCubit, CommentsState>(
                      builder: (context, state) {
                        final isSubmitting =
                            state is CommentsLoaded && state.isSubmitting;
                        return TextButton(
                          onPressed: isSubmitting ? null : _submitComment,
                          child: isSubmitting
                              ? SizedBox(
                                  height: 16.h,
                                  width: 16.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Post',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.onReplyTap,
    this.isReply = false,
  });

  final CommentModel comment;
  final void Function(CommentModel) onReplyTap;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isReply ? 56.w : 16.w,
            bottom: 8.h,
            right: 15,
            top: 8.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ProfileScreen.route(userId: comment.userId),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: isReply ? 12.r : 16.r,
                  backgroundImage: comment.userProfileUrl != null
                      ? NetworkImage(comment.userProfileUrl!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: comment.userProfileUrl == null
                      ? Icon(
                          Icons.person,
                          size: isReply ? 14.r : 18.r,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push<void>(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (_) => ProfileScreen(
                                                userId: comment.userId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          '${comment.userName} ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: _formatTime(comment.createdAt),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (comment.mediaUrl != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.network(
                                      comment.mediaUrl!,
                                      height: 150.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (comment.content.isNotEmpty)
                                Text(
                                  comment.content,
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context
                              .read<CommentsCubit>()
                              .toggleCommentLike(comment.id),
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.w, top: 4.h),
                            child: Icon(
                              comment.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20.sp,
                              color: comment.isLiked ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        if (comment.likes > 0) ...[
                          Text(
                            '${comment.likes} like',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16.w),
                        ],
                        GestureDetector(
                          onTap: () => onReplyTap(comment),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (comment.replies.isNotEmpty)
          ...comment.replies.map(
            (reply) => _CommentItem(
              comment: reply,
              onReplyTap: onReplyTap,
              isReply: true,
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 7) {
      return DateFormat('MMM d').format(time);
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}
