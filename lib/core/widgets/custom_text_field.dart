import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.label,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.controller,
    this.onChanged,
    this.validator,
    super.key,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grey400 = Colors.grey[400];
    final grey300 = Colors.grey[300];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          cursorColor: theme.primaryColor,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14.sp, color: grey400),
            prefixIcon: Container(
              padding: EdgeInsets.only(right: 12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    icon,
                    size: 15.sp,
                    color: grey400?.withValues(alpha: 0.8),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '|',
                    style: TextStyle(
                      color: grey300?.withValues(alpha: 0.5),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: grey400?.withValues(alpha: 0.6),
                      size: 20.sp,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: grey300!, width: 0.5.h),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.primaryColor, width: 1.h),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 0.5.h),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.h),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
