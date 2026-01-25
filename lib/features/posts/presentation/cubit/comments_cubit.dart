import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/posts/domain/models/comment_model.dart';
import 'package:osox/features/posts/domain/repositories/comment_repository.dart';
import 'package:osox/features/posts/presentation/cubit/comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository, this.postId) : super(const CommentsInitial());

  final ICommentRepository _repository;
  final String postId;

  Future<void> loadComments() async {
    emit(const CommentsLoading());
    try {
      final comments = await _repository.getComments(postId);
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> addComment(String content, {String? mediaUrl}) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final newComment = await _repository.addComment(
        postId: postId,
        content: content,
        mediaUrl: mediaUrl,
      );

      final updatedComments = [newComment, ...currentState.comments];
      emit(
        currentState.copyWith(
          comments: updatedComments,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(isSubmitting: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> addReply({
    required String parentId,
    required String content,
    String? mediaUrl,
  }) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final newReply = await _repository.addComment(
        postId: postId,
        content: content,
        parentId: parentId,
        mediaUrl: mediaUrl,
      );

      // Update the parent comment's replies locally for immediate feedback
      final updatedComments = currentState.comments.map((comment) {
        if (comment.id == parentId) {
          return comment.copyWith(replies: [...comment.replies, newReply]);
        }
        return comment;
      }).toList();

      emit(
        currentState.copyWith(
          comments: updatedComments,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(isSubmitting: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleCommentLike(String commentId, {String? parentId}) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    final commentToToggle = _findComment(currentState.comments, commentId);
    if (commentToToggle == null) return;

    final wasLiked = commentToToggle.isLiked;

    final updatedComments = _updateLikeInList(
      currentState.comments,
      commentId,
      !wasLiked,
    );

    emit(currentState.copyWith(comments: updatedComments));

    try {
      if (wasLiked) {
        await _repository.unlikeComment(commentId);
      } else {
        await _repository.likeComment(commentId);
      }
    } catch (e) {
      // Revert on error
      final revertedComments = _updateLikeInList(
        updatedComments,
        commentId,
        wasLiked,
      );
      emit(currentState.copyWith(comments: revertedComments));
    }
  }

  List<CommentModel> _updateLikeInList(
    List<CommentModel> comments,
    String commentId,
    bool isLiked,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          isLiked: isLiked,
          likes: isLiked ? comment.likes + 1 : comment.likes - 1,
        );
      }

      if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _updateLikeInList(comment.replies, commentId, isLiked),
        );
      }

      return comment;
    }).toList();
  }

  CommentModel? _findComment(List<CommentModel> comments, String commentId) {
    for (final comment in comments) {
      if (comment.id == commentId) return comment;
      final foundInReplies = _findComment(comment.replies, commentId);
      if (foundInReplies != null) return foundInReplies;
    }
    return null;
  }
}
