import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';
import 'package:osox/features/chat/domain/repositories/chat_repository.dart';
import 'package:osox/features/chat/presentation/cubit/message_cubit.dart';
import 'package:osox/features/chat/presentation/cubit/message_state.dart';
import 'package:osox/features/chat/presentation/view/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    super.key,
  });

  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      if (context.mounted) {
        context.read<MessageCubit>().sendMediaMessage(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MessageCubit(getIt<IChatRepository>(), widget.otherUserId),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundImage: widget.otherUserAvatar.isNotEmpty
                    ? NetworkImage(widget.otherUserAvatar)
                    : null,
                backgroundColor: Colors.grey[200],
                child: widget.otherUserAvatar.isEmpty
                    ? Icon(Icons.person, size: 20.r, color: Colors.grey[400])
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Active now', // Placeholder for real online status
                      style: TextStyle(fontSize: 12.sp, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () {},
            ),
            IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessageCubit, MessageState>(
                builder: (context, state) {
                  if (state is MessageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MessageLoaded) {
                    if (state.messages.isEmpty) {
                      return const Center(child: Text('Start a conversation'));
                    }
                    return ListView.builder(
                      reverse: true, // Show newest at bottom
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return MessageBubble(message: message);
                      },
                    );
                  } else if (state is MessageError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        final replyingTo = (state is MessageLoaded) ? state.replyingTo : null;

        return Container(
          padding: EdgeInsets.only(
            left: 8.w,
            right: 16.w,
            bottom: MediaQuery.of(context).padding.bottom + 10.h,
            top: 10.h,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingTo != null) _buildReplyPreview(context, replyingTo),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () => _pickImage(ImageSource.camera, context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: () => _pickImage(ImageSource.gallery, context),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final content = _messageController.text;
                        if (content.isNotEmpty) {
                          context.read<MessageCubit>().sendMessage(content);
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview(BuildContext context, MessageModel message) {
    return Container(
      padding: EdgeInsets.all(8.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  message.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20.r, color: Colors.grey),
            onPressed: () => context.read<MessageCubit>().cancelReply(),
          ),
        ],
      ),
    );
  }
}
