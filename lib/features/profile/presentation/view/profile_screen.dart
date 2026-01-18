import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:osox/features/profile/presentation/cubit/profile_state.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_header.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_post_grid.dart';
import 'package:osox/features/profile/presentation/view/widgets/profile_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    context.read<ProfileCubit>().loadProfile();
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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 14.sp,
              color: isDark ? Colors.white : Colors.black,
            ),
            SizedBox(width: 4.w),
            Text(
              'jacob_w',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: isDark ? Colors.white : Colors.grey,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ProfileShimmer();
          }

          if (state is ProfileLoaded) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    fullName: state.fullName,
                    bio: state.bio,
                    profilePicUrl: state.profilePicUrl,
                    postsCount: state.postsCount,
                    followersCount: state.followersCount,
                    followingCount: state.followingCount,
                  ),
                ),
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
