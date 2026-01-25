import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';
import 'package:osox/features/chat/domain/repositories/chat_repository.dart';
import 'package:osox/features/chat/presentation/cubit/message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  MessageCubit(this._chatRepository, this.otherUserId)
    : super(MessageInitial()) {
    _watchMessages();
  }

  final IChatRepository _chatRepository;
  final String otherUserId;
  StreamSubscription<List<MessageModel>>? _messageSubscription;

  void _watchMessages() {
    emit(MessageLoading());
    _messageSubscription = _chatRepository
        .watchMessages(otherUserId)
        .listen(
          (messages) {
            final currentState = state;
            if (currentState is MessageLoaded) {
              emit(currentState.copyWith(messages: messages));
            } else {
              emit(MessageLoaded(messages: messages));
            }
            // Mark as read when messages are received in the active chat
            _chatRepository.markAsRead(otherUserId);
          },
          onError: (Object error) {
            emit(MessageError(error.toString()));
          },
        );
  }

  void setReplyMessage(MessageModel message) {
    final currentState = state;
    if (currentState is MessageLoaded) {
      emit(currentState.copyWith(replyingTo: message));
    }
  }

  void cancelReply() {
    final currentState = state;
    if (currentState is MessageLoaded) {
      emit(currentState.copyWith(clearReply: true));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    try {
      final currentState = state;
      if (currentState is MessageLoaded && currentState.replyingTo != null) {
        await _chatRepository.replyToMessage(
          otherUserId,
          content.trim(),
          currentState.replyingTo!.id,
        );
        emit(currentState.copyWith(clearReply: true));
      } else {
        await _chatRepository.sendMessage(otherUserId, content.trim());
      }
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> sendMediaMessage(String filePath, {String content = ''}) async {
    try {
      await _chatRepository.sendMediaMessage(otherUserId, content, filePath);
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> reactToMessage(String messageId, String emoji) async {
    try {
      await _chatRepository.reactToMessage(messageId, emoji);
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(messageId);
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
