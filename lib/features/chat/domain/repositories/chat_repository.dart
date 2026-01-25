import 'package:osox/features/chat/domain/models/conversation_model.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';

abstract class IChatRepository {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages(String otherUserId);
  Future<void> sendMessage(String receiverId, String content);
  Future<void> sendMediaMessage(
    String receiverId,
    String content,
    String filePath,
  );
  Future<void> replyToMessage(
    String receiverId,
    String content,
    String parentId,
  );
  Future<void> reactToMessage(String messageId, String emoji);
  Future<void> deleteMessage(String messageId);
  Future<void> markAsRead(String otherUserId);
  Stream<List<MessageModel>> watchMessages(String otherUserId);
  Stream<List<ConversationModel>> watchConversations();
}
