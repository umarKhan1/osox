import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.fullName,
    required this.bio,
    required this.profilePicUrl,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    super.key,
  });

  final String fullName;
  final String bio;
  final String profilePicUrl;
  final int postsCount;
  final int followersCount;
  final int followingCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundImage: CachedNetworkImageProvider(profilePicUrl),
                ),
              ),
              const Spacer(),
              _buildStatItem('Posts', postsCount.toString()),
              _buildStatItem('Followers', followersCount.toString()),
              _buildStatItem('Following', followingCount.toString()),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            fullName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          SizedBox(height: 2.h),
          Text(bio, style: TextStyle(fontSize: 14.sp, height: 1.3)),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
