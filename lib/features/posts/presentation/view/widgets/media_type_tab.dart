import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/core/constants/app_colors.dart';

class MediaTypeTab extends StatelessWidget {
  const MediaTypeTab({
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    super.key,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
