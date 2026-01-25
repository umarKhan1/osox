import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:osox/features/chat/presentation/cubit/chat_list_state.dart';
import 'package:osox/features/chat/presentation/view/widgets/conversation_tile.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<ChatListCubit, ChatListState>(
              builder: (context, state) {
                if (state is ChatListLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatListLoaded) {
                  if (state.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 64.r,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.conversations.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[100]),
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () => context.push(
                          '/chat/${conversation.otherUserId}',
                          extra: {
                            'name': conversation.otherUserName,
                            'avatar': conversation.otherUserAvatar,
                          },
                        ),
                      );
                    },
                  );
                } else if (state is ChatListError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
