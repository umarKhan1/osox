import 'package:equatable/equatable.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  const MessageLoaded({required this.messages, this.replyingTo});

  final List<MessageModel> messages;
  final MessageModel? replyingTo;

  @override
  List<Object?> get props => [messages, replyingTo];

  MessageLoaded copyWith({
    List<MessageModel>? messages,
    MessageModel? replyingTo,
    bool clearReply = false,
  }) {
    return MessageLoaded(
      messages: messages ?? this.messages,
      replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
    );
  }
}

class MessageError extends MessageState {
  const MessageError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
