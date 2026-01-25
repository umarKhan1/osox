import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/features/activity/presentation/view/activity_screen.dart';
import 'package:osox/features/home/presentation/view/home_screen.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/profile/presentation/view/profile_screen.dart';
import 'package:osox/features/search/domain/repositories/search_repository.dart';
import 'package:osox/features/search/presentation/cubit/search_cubit.dart';
import 'package:osox/features/search/presentation/view/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    BlocProvider(
      create: (context) =>
          SearchCubit(getIt<IPostRepository>(), getIt<ISearchRepository>()),
      child: const SearchScreen(),
    ),
    const SizedBox.shrink(), // Placeholder for the 'Add' tab
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Tapping the '+' icon opens media selection
      context.push('/media-selection');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? Colors.black : Colors.white,
          selectedItemColor: isDark ? Colors.white : Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 28.sp,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'Add',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: _selectedIndex == 4
                      ? Border.all(color: isDark ? Colors.white : Colors.black)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundImage: const NetworkImage(
                    'https://i.pravatar.cc/150?u=current_user',
                  ),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
