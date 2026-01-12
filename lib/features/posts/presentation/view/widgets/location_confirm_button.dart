import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationConfirmButton extends StatelessWidget {
  const LocationConfirmButton({
    required this.hasSelection,
    required this.onConfirm,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD73A),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      child: Text(
        hasSelection ? 'Confirm Location' : 'Use Current Location',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
