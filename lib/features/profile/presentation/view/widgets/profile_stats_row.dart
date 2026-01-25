import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.onFollowersTap,
    this.onFollowingTap,
    super.key,
  });

  final int postsCount;
  final int followersCount;
  final int followingCount;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem('Posts', postsCount.toString(), null),
        _buildStatItem('Followers', followersCount.toString(), onFollowersTap),
        _buildStatItem('Following', followingCount.toString(), onFollowingTap),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.black, // Adjust for dark mode if needed
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
