import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpTitle extends StatelessWidget {
  const SignUpTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign up',
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 45.w,
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
