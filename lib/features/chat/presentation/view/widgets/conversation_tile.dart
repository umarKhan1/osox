import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:osox/features/chat/domain/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.grey[200],
        backgroundImage: conversation.otherUserAvatar.isNotEmpty
            ? NetworkImage(conversation.otherUserAvatar)
            : null,
        child: conversation.otherUserAvatar.isEmpty
            ? Icon(Icons.person, color: Colors.grey[400], size: 30.r)
            : null,
      ),
      title: Text(
        conversation.otherUserName,
        style: TextStyle(
          fontWeight: conversation.unreadCount > 0
              ? FontWeight.bold
              : FontWeight.w600,
          fontSize: 16.sp,
        ),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: conversation.unreadCount > 0
              ? (isDark ? Colors.white : Colors.black)
              : Colors.grey[600],
          fontWeight: conversation.unreadCount > 0
              ? FontWeight.w500
              : FontWeight.normal,
          fontSize: 14.sp,
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.lastMessageTime),
            style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          ),
          if (conversation.unreadCount > 0)
            Container(
              margin: EdgeInsets.only(top: 1.h),
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return DateFormat.jm().format(time); // e.g. 1:35 PM
    } else if (now.difference(time).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(time); // e.g. Jan 23
    }
  }
}
