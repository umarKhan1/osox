import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/chat/domain/models/conversation_model.dart';
import 'package:osox/features/chat/domain/repositories/chat_repository.dart';
import 'package:osox/features/chat/presentation/cubit/chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit(this._chatRepository) : super(ChatListInitial()) {
    _watchConversations();
  }

  final IChatRepository _chatRepository;
  StreamSubscription<List<ConversationModel>>? _conversationSubscription;

  void _watchConversations() {
    emit(ChatListLoading());
    _conversationSubscription = _chatRepository.watchConversations().listen(
      (conversations) {
        emit(ChatListLoaded(conversations: conversations));
      },
      onError: (Object error) {
        emit(ChatListError(error.toString()));
      },
    );
  }

  Future<void> refreshConversations() async {
    try {
      final conversations = await _chatRepository.getConversations();
      emit(ChatListLoaded(conversations: conversations));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _conversationSubscription?.cancel();
    return super.close();
  }
}
