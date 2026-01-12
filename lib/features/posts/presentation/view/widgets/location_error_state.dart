import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationErrorState extends StatelessWidget {
  const LocationErrorState({
    required this.message,
    required this.onRetry,
    required this.onGoBack,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Error: $message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          SizedBox(height: 8.h),
          TextButton(onPressed: onGoBack, child: const Text('Go Back')),
        ],
      ),
    );
  }
}
