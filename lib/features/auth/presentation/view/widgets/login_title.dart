import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/core/constants/app_strings.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.signIn,
          style: TextStyle(
            fontSize: 33.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 65.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(2.5.r),
          ),
        ),
      ],
    );
  }
}
