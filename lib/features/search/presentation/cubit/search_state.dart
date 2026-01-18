import 'package:equatable/equatable.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  const SearchLoaded({required this.posts});
  final List<PostModel> posts;

  @override
  List<Object?> get props => [posts];
}

class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
