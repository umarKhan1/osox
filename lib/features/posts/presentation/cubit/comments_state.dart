import 'package:equatable/equatable.dart';
import 'package:osox/features/posts/domain/models/comment_model.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  const CommentsLoaded({
    required this.comments,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<CommentModel> comments;
  final bool isSubmitting;
  final String? errorMessage;

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [comments, isSubmitting, errorMessage];
}

class CommentsError extends CommentsState {
  const CommentsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
