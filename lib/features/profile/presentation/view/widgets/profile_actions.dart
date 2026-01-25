import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    required this.isMyProfile,
    required this.isFollowing,
    required this.isFollower,
    required this.onEditProfile,
    required this.onFollow,
    required this.onUnfollow,
    required this.onMessage,
    super.key,
  });

  final bool isMyProfile;
  final bool isFollowing;
  final bool isFollower;
  final VoidCallback onEditProfile;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isMyProfile) {
      return _buildFullWidthButton(
        label: 'Edit Profile',
        onPressed: onEditProfile,
        isDark: isDark,
      );
    }

    // Mutual Follow: Message + Unfollow
    if (isFollowing && isFollower) {
      return Row(
        children: [
          Expanded(
            child: _buildSecondaryButton(
              label: 'Message',
              onPressed: onMessage,
              isDark: isDark,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildSecondaryButton(
              label: 'Following',
              onPressed: onUnfollow,
              isDark: isDark,
              showDropdownIcon: true,
            ),
          ),
        ],
      );
    }

    // I follow them (One-way): Following button only (full width)
    if (isFollowing) {
      return _buildSecondaryButton(
        label: 'Following',
        onPressed: onUnfollow,
        isDark: isDark,
        showDropdownIcon: true,
      );
    }

    // They follow me (One-way): Follow Back button (full width)
    if (isFollower) {
      return _buildPrimaryButton(context, 'Follow Back');
    }

    // No relationship: Follow button (full width)
    return _buildPrimaryButton(context, 'Follow');
  }

  Widget _buildPrimaryButton(BuildContext context, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 8.h),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildFullWidthButton({
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 8.h),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
    bool showDropdownIcon = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(vertical: 8.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          if (showDropdownIcon) ...[
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ],
      ),
    );
  }
}
