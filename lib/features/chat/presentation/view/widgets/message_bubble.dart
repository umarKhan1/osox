import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';
import 'package:osox/features/chat/presentation/cubit/message_cubit.dart';
import 'package:osox/features/chat/presentation/view/widgets/message_interaction_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({required this.message, super.key});

  final MessageModel message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final GlobalKey _bubbleKey = GlobalKey();

  void _showInteractionMenu(BuildContext context) {
    final renderBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final messageCubit = context.read<MessageCubit>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: MessageInteractionOverlay(
            message: widget.message,
            messagePosition: position,
            messageSize: size,
            onReact: (emoji) {
              messageCubit.reactToMessage(widget.message.id, emoji);
            },
            onAction: (action) {
              if (action == 'reply') {
                messageCubit.setReplyMessage(widget.message);
              } else if (action == 'delete') {
                messageCubit.deleteMessage(widget.message.id);
              } else if (action == 'copy') {
                // Clipboard.setData(
                //   ClipboardData(text: widget.message.content),
                // );
              }
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = widget.message.senderId == currentUserId;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(widget.message.id),
      direction: widget.message.isDeleted
          ? DismissDirection.none
          : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        if (!widget.message.isDeleted) {
          context.read<MessageCubit>().setReplyMessage(widget.message);
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        child: Icon(Icons.reply, color: theme.primaryColor, size: 24.sp),
      ),
      child: GestureDetector(
        onLongPress: widget.message.isDeleted
            ? null
            : () => _showInteractionMenu(context),
        child: Align(
          key: _bubbleKey,
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    constraints: BoxConstraints(maxWidth: 0.7.sw),
                    padding: EdgeInsets.all(
                      widget.message.imageUrl != null ? 4.r : 10.r,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.black
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(isMe ? 16.r : 2.r),
                        bottomRight: Radius.circular(isMe ? 2.r : 16.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.message.replyToId != null)
                            _buildReplyHeader(context),
                          if (widget.message.imageUrl != null &&
                              !widget.message.isDeleted)
                            Image.network(
                              widget.message.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.message.imageUrl != null
                                  ? 8.w
                                  : 6.w,
                              vertical: widget.message.imageUrl != null
                                  ? 8.h
                                  : 0,
                            ),
                            child: Text(
                              widget.message.isDeleted
                                  ? 'This message was deleted'
                                  : widget.message.content,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black),
                                fontSize: 15.sp,
                                fontStyle: widget.message.isDeleted
                                    ? FontStyle.italic
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.message.reactions.isNotEmpty &&
                      !widget.message.isDeleted)
                    Positioned(
                      bottom: -8.h,
                      right: isMe ? 12.w : null,
                      left: isMe ? null : 12.w,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.message.reactions.entries.map((e) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),
                            margin: EdgeInsets.only(right: 4.w),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[850] : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark
                                    ? Colors.black
                                    : Colors.grey[300]!,
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              e.key,
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.jm().format(widget.message.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10.sp,
                      ),
                    ),
                    if (isMe && !widget.message.isDeleted) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.done_all,
                        size: 14.sp,
                        color: widget.message.isRead
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor, width: 3),
        ),
      ),
      child: Text(
        'Replied to a message',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
