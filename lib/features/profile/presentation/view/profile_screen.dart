import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/profile/domain/repositories/profile_repository.dart';
import 'package:osox/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:osox/features/profile/presentation/cubit/profile_state.dart';
import 'package:osox/features/profile/presentation/view/edit_profile_screen.dart';
import 'package:osox/features/profile/presentation/view/follow_list_screen.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_actions.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_avatar.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_post_grid.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_shimmer.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_stats_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.userId, super.key});

  final String? userId;

  static Widget route({String? userId}) {
    return BlocProvider(
      create: (context) =>
          ProfileCubit(getIt<IPostRepository>(), getIt<IProfileRepository>()),
      child: ProfileScreen(userId: userId),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProfileCubit>().loadProfile(userId: widget.userId);
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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ProfileShimmer();
          }

          if (state is ProfileLoaded) {
            return CustomScrollView(
              slivers: [
                // Custom App Bar (Username + Menu)
                SliverAppBar(
                  floating: true,
                  backgroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                // Profile Header Data
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ProfileAvatar(
                              imageUrl: state.profilePicUrl,
                              hasStory: state.hasStories,
                              onTap: () {
                                if (state.hasStories) {
                                  // Open story viewer
                                  // context.push('/story-view', extra: state.stories);
                                }
                              },
                            ),
                            const Spacer(),
                            ProfileStatsRow(
                              postsCount: state.postsCount,
                              followersCount: state.followersCount,
                              followingCount: state.followingCount,
                              onFollowersTap: () async {
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => FollowListScreen(
                                      userId: state.userId,
                                      fullName: state.fullName,
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  context.read<ProfileCubit>().loadProfile(
                                    userId: state.userId,
                                  );
                                }
                              },
                              onFollowingTap: () async {
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => FollowListScreen(
                                      userId: state.userId,
                                      fullName: state.fullName,
                                      initialTab: 1,
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  context.read<ProfileCubit>().loadProfile(
                                    userId: state.userId,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        if (state.bio.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            state.bio,
                            style: TextStyle(fontSize: 14.sp, height: 1.3),
                          ),
                        ],
                        SizedBox(height: 16.h),
                        ProfileActions(
                          isMyProfile:
                              state.userId ==
                              Supabase.instance.client.auth.currentUser?.id,
                          isFollowing: state.isFollowing,
                          isFollower: state.isFollower,
                          onEditProfile: () async {
                            await Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ProfileCubit>(),
                                  child: const EditProfileScreen(),
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                            if (context.mounted) {
                              context.read<ProfileCubit>().loadProfile(
                                userId: state.userId,
                              );
                            }
                          },
                          onFollow: () => context
                              .read<ProfileCubit>()
                              .followUser(state.userId),
                          onUnfollow: () => context
                              .read<ProfileCubit>()
                              .unfollowUser(state.userId),
                          onMessage: () => context.push(
                            '/chat/${state.userId}',
                            extra: {
                              'name': state.fullName,
                              'avatar': state.profilePicUrl,
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),

                // Grid Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: isDark ? Colors.white : Colors.black,
                      labelColor: isDark ? Colors.white : Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorWeight: 1,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on_outlined)),
                        Tab(icon: Icon(Icons.person_pin_outlined)),
                      ],
                    ),
                    isDark ? Colors.black : Colors.white,
                  ),
                ),

                // Post Grid
                ProfilePostGrid(posts: state.posts),
              ],
            );
          }

          if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
