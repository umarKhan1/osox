import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.replyToId,
    this.reactions = const {},
    this.isDeleted = false,
  });
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final reactions = <String, List<String>>{};
    try {
      final reactionsData = json['reactions'];
      if (reactionsData is Map) {
        reactionsData.forEach((key, value) {
          if (value is Iterable) {
            reactions[key.toString()] = List<String>.from(
              value.map((e) => e.toString()),
            );
          }
        });
      }
    } catch (e) {
      // Silence parsing errors
    }

    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      replyToId: json['reply_to_id'] as String?,
      reactions: reactions,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? replyToId;
  final Map<String, List<String>> reactions;
  final bool isDeleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
      'reply_to_id': replyToId,
      'reactions': reactions,
      'is_deleted': isDeleted,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? replyToId,
    Map<String, List<String>>? reactions,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    receiverId,
    content,
    createdAt,
    isRead,
    imageUrl,
    replyToId,
    reactions,
    isDeleted,
  ];
}
