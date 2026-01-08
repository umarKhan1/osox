import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final effectiveTextColor =
        textColor ?? (isLight ? Colors.black : Colors.white);

    return SizedBox(
      width: width ?? 327.w,
      height: height ?? 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: effectiveTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: effectiveTextColor,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 8.w),
              Icon(icon, size: 20.sp, color: effectiveTextColor),
            ],
          ],
        ),
      ),
    );
  }
}
