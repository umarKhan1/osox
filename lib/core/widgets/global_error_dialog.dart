import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalErrorDialog extends StatelessWidget {
  const GlobalErrorDialog({
    required this.message,
    this.title = 'Error',
    this.onConfirm,
    super.key,
  });
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  static void show(
    BuildContext context, {
    required String message,
    String title = 'Error',
    VoidCallback? onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => GlobalErrorDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: AlertDialog(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 28.sp),
                  SizedBox(width: 10.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // ignore: prefer_null_aware_method_calls
                    if (onConfirm != null) onConfirm!();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
