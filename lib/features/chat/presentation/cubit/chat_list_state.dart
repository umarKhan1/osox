import 'package:equatable/equatable.dart';
import 'package:osox/features/chat/domain/models/conversation_model.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  const ChatListLoaded({required this.conversations});

  final List<ConversationModel> conversations;

  @override
  List<Object?> get props => [conversations];
}

class ChatListError extends ChatListState {
  const ChatListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
