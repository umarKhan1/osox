import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/profile/presentation/cubit/follow_list_cubit.dart';
import 'package:osox/features/profile/presentation/view/profile_screen.dart';
import 'package:osox/features/search/domain/models/user_search_result.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({
    required this.userId,
    required this.fullName,
    this.initialTab = 0,
    super.key,
  });

  final String userId;
  final String fullName;
  final int initialTab;

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    context.read<FollowListCubit>().loadLists(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          widget.fullName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? Colors.white : Colors.black,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: BlocBuilder<FollowListCubit, FollowListState>(
        builder: (context, state) {
          if (state is FollowListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FollowListLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(state.followers, isFollowingList: false),
                _buildUserList(state.following, isFollowingList: true),
              ],
            );
          }

          if (state is FollowListError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserList(
    List<UserSearchResult> users, {
    required bool isFollowingList,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          isFollowingList ? 'No following' : 'No followers',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return GestureDetector(
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ProfileScreen.route(userId: user.id),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl != null
                  ? CachedNetworkImageProvider(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.email),
            trailing: isFollowingList
                ? OutlinedButton(
                    onPressed: () {
                      context.read<FollowListCubit>().unfollowUser(
                        widget.userId,
                        user.id,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: const Text('Following'),
                  )
                : OutlinedButton(
                    onPressed: () {
                      context.read<FollowListCubit>().removeFollower(
                        widget.userId,
                        user.id,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: const Text('Remove'),
                  ),
          ),
        );
      },
    );
  }
}
