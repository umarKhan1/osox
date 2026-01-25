import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/profile/presentation/view/profile_screen.dart';
import 'package:osox/features/search/presentation/cubit/search_cubit.dart';
import 'package:osox/features/search/presentation/cubit/search_state.dart';
import 'package:osox/features/search/presentation/view/widgets/explore_tile.dart';
import 'package:osox/features/search/presentation/view/widgets/user_search_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().loadExploreFeed();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<SearchCubit>().searchUsers(query);
                    },
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
              ),
            ),

            // Content based on state
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // User search results
                if (state is SearchUsersLoaded) {
                  if (state.users.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = state.users[index];
                      return UserSearchTile(
                        user: user,
                        onTap: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ProfileScreen.route(userId: user.id),
                            ),
                          );
                        },
                      );
                    }, childCount: state.users.length),
                  );
                }

                // Explore feed (posts grid)
                if (state is SearchLoaded) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      itemBuilder: (context, index) {
                        final post = state.posts[index % state.posts.length];
                        return AspectRatio(
                          aspectRatio: _getAspectRatio(index),
                          child: ExploreTile(
                            post: post,
                            index: index,
                            onTap: () async {
                              await context.push('/post-detail', extra: post);
                              if (context.mounted) {
                                context.read<SearchCubit>().loadExploreFeed();
                              }
                            },
                          ),
                        );
                      },
                      childCount: state.posts.length * 3, // Repeat for demo
                    ),
                  );
                }

                if (state is SearchError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${state.message}')),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  double _getAspectRatio(int index) {
    // 0, 1, 2, 3, 4, 5...
    // We want some to be tall or standard to create mosaic look
    // This is a simplified version of the Instagram pattern
    final pattern = <double>[1, 1, 0.5, 1, 1, 1];
    // 0.5 is tall (2 rows)
    return pattern[index % pattern.length];
  }
}
