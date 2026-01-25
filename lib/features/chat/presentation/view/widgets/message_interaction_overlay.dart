import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:osox/features/chat/domain/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageInteractionOverlay extends StatelessWidget {
  const MessageInteractionOverlay({
    required this.message,
    required this.messagePosition,
    required this.messageSize,
    required this.onReact,
    required this.onAction,
    super.key,
  });

  final MessageModel message;
  final Offset messagePosition;
  final Size messageSize;
  final void Function(String emoji) onReact;
  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final commonEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = message.senderId == currentUserId;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Blurred Background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),

          // 2. Reactions Row (Positioned ABOVE message)
          Positioned(
            top: messagePosition.dy - 55.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: commonEmojis.map((emoji) {
                    final isSelected =
                        message.reactions[emoji]?.contains(currentUserId) ??
                        false;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onReact(emoji);
                        Navigator.pop(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // 3. Focused Message Bubble
          Positioned(
            top: messagePosition.dy,
            left: messagePosition.dx,
            width: messageSize.width,
            child: _DummyBubble(message: message, isMe: isMe, isDark: isDark),
          ),

          // 4. Actions Menu (Positioned BELOW message)
          Positioned(
            top: messagePosition.dy + messageSize.height + 6.h,
            left: isMe ? null : (messagePosition.dx + 12.w),
            right: isMe
                ? (MediaQuery.of(context).size.width -
                      (messagePosition.dx + messageSize.width) +
                      12.w)
                : null,
            child: Container(
              width: 140.w,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionItem(
                    icon: Icons.reply_rounded,
                    label: 'Reply',
                    onTap: () => onAction('reply'),
                  ),
                  _buildActionItem(
                    icon: Icons.content_copy_rounded,
                    label: 'Copy',
                    onTap: () => onAction('copy'),
                  ),
                  if (isMe)
                    _buildActionItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      isDanger: true,
                      onTap: () => onAction('delete'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: isDanger ? Colors.red : null, size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isDanger ? Colors.red : null,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DummyBubble extends StatelessWidget {
  const _DummyBubble({
    required this.message,
    required this.isMe,
    required this.isDark,
  });
  final MessageModel message;
  final bool isMe;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
              constraints: BoxConstraints(maxWidth: 0.7.sw),
              padding: EdgeInsets.all(message.imageUrl != null ? 4.r : 10.r),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null && !message.isDeleted)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: message.imageUrl != null ? 8.w : 6.w,
                      vertical: message.imageUrl != null ? 8.h : 0,
                    ),
                    child: Text(
                      message.isDeleted
                          ? 'This message was deleted'
                          : message.content,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 15.sp,
                        fontStyle: message.isDeleted ? FontStyle.italic : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (message.reactions.isNotEmpty && !message.isDeleted)
              Positioned(
                bottom: -10,
                right: isMe ? 20.w : null,
                left: isMe ? null : 20.w,
                child: Row(
                  children: message.reactions.entries.map((e) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      margin: EdgeInsets.only(right: 4.w),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(e.key, style: TextStyle(fontSize: 12.sp)),
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
                DateFormat.jm().format(message.createdAt),
                style: TextStyle(color: Colors.grey[300], fontSize: 10.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
