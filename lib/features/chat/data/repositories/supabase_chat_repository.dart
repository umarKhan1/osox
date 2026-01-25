import 'dart:async';
import 'dart:io';
import 'package:osox/features/chat/domain/models/conversation_model.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';
import 'package:osox/features/chat/domain/repositories/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChatRepository implements IChatRepository {
  SupabaseChatRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<ConversationModel>> getConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('messages')
        .select('''
          *,
          sender:profiles!messages_sender_id_fkey(id, full_name, avatar_url),
          receiver:profiles!messages_receiver_id_fkey(id, full_name, avatar_url)
        ''')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    return _groupMessagesIntoConversations(response as List, userId);
  }

  @override
  Future<List<MessageModel>> getMessages(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('messages')
        .select()
        .or(
          // ignore: lines_longer_than_80_chars
          'and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)',
        )
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sendMessage(String receiverId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('messages').insert({
      'sender_id': userId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  @override
  Future<void> sendMediaMessage(
    String receiverId,
    String content,
    String filePath,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = '${DateTime.now().microsecondsSinceEpoch}.$fileExt';
    final storagePath = 'chat/$userId/$fileName';

    await _supabase.storage
        .from('chat_media')
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final imageUrl = _supabase.storage
        .from('chat_media')
        .getPublicUrl(storagePath);

    await _supabase.from('messages').insert({
      'sender_id': userId,
      'receiver_id': receiverId,
      'content': content,
      'image_url': imageUrl,
    });
  }

  @override
  Future<void> replyToMessage(
    String receiverId,
    String content,
    String parentId,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('messages').insert({
      'sender_id': userId,
      'receiver_id': receiverId,
      'content': content,
      'reply_to_id': parentId,
    });
  }

  @override
  Future<void> reactToMessage(String messageId, String emoji) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final msgRes = await _supabase
        .from('messages')
        .select('reactions')
        .eq('id', messageId)
        .single();

    final currentReactions = Map<String, dynamic>.from(
      msgRes['reactions'] as Map? ?? {},
    );

    final updatedReactions = <String, dynamic>{};

    // 1. Remove user from all EXISTING reactions (Except the current one we
    // might be toggling)
    currentReactions.forEach((key, value) {
      if (key != emoji) {
        final users = List<String>.from(value as Iterable? ?? [])
          ..remove(userId);
        if (users.isNotEmpty) {
          updatedReactions[key] = users;
        }
      }
    });

    // 2. Toggle the TARGET emoji
    final targetEmojiUsers = List<String>.from(
      currentReactions[emoji] as Iterable? ?? [],
    );

    if (targetEmojiUsers.contains(userId)) {
      targetEmojiUsers.remove(userId);
    } else {
      targetEmojiUsers.add(userId);
    }

    if (targetEmojiUsers.isNotEmpty) {
      updatedReactions[emoji] = targetEmojiUsers;
    }

    await _supabase
        .from('messages')
        .update({'reactions': updatedReactions})
        .eq('id', messageId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('messages')
        .update({
          'content': 'This message was deleted',
          'is_deleted': true,
          'image_url': null,
        })
        .match({'id': messageId, 'sender_id': userId});
  }

  @override
  Future<void> markAsRead(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('messages').update({'is_read': true}).match({
      'sender_id': otherUserId,
      'receiver_id': userId,
      'is_read': false,
    });
  }

  @override
  Stream<List<MessageModel>> watchMessages(String otherUserId) {
    final controller = StreamController<List<MessageModel>>();

    // Initial fetch
    getMessages(otherUserId).then((messages) {
      if (!controller.isClosed) controller.add(messages);
    });

    // Subscribe to changes and refetch
    final channel = _supabase.channel('chat_messages_$otherUserId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            getMessages(otherUserId).then((messages) {
              if (!controller.isClosed) controller.add(messages);
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<ConversationModel>> watchConversations() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .asyncMap((data) async {
          return _groupMessagesIntoConversations(
            data,
            userId,
            fetchProfiles: true,
          );
        });
  }

  Future<List<ConversationModel>> _groupMessagesIntoConversations(
    List<dynamic> data,
    String userId, {
    bool fetchProfiles = false,
  }) async {
    final conversations = <String, ConversationModel>{};

    for (final json in data) {
      final msg = json as Map<String, dynamic>;
      final sId = msg['sender_id'] as String;
      final rId = msg['receiver_id'] as String;
      final otherUserId = sId == userId ? rId : sId;

      if (conversations.containsKey(otherUserId)) {
        if (msg['is_read'] != true && rId == userId) {
          final existing = conversations[otherUserId]!;
          conversations[otherUserId] = existing.copyWith(
            unreadCount: existing.unreadCount + 1,
            isRead: false,
          );
        }
        continue;
      }

      Map<String, dynamic>? otherProfile;
      if (fetchProfiles) {
        final profileRes = await _supabase
            .from('profiles')
            .select()
            .eq('id', otherUserId)
            .single();
        otherProfile = profileRes as Map<String, dynamic>?;
      } else {
        otherProfile =
            (sId == userId ? msg['receiver'] : msg['sender'])
                as Map<String, dynamic>?;
      }

      conversations[otherUserId] = ConversationModel(
        id: otherUserId,
        otherUserId: otherUserId,
        otherUserName: otherProfile?['full_name'] as String? ?? 'User',
        otherUserAvatar: otherProfile?['avatar_url'] as String? ?? '',
        lastMessage: msg['content'] as String,
        lastMessageTime: DateTime.parse(msg['created_at'] as String),
        unreadCount: (msg['is_read'] != true && rId == userId) ? 1 : 0,
        isRead: msg['is_read'] as bool? ?? true,
      );
    }

    return conversations.values.toList();
  }
}
