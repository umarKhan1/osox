import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/core/constants/app_colors.dart';

class CameraCaptureButton extends StatefulWidget {
  const CameraCaptureButton({
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
    super.key,
  });

  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  State<CameraCaptureButton> createState() => _CameraCaptureButtonState();
}

class _CameraCaptureButtonState extends State<CameraCaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderController;
  Timer? _longPressTimer;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2s recording limit as requested
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (!_isRecording) {
      widget.onTap();
    }
  }

  void _handleLongPressStart() {
    _longPressTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isRecording = true;
      });
      widget.onHoldStart();
      _borderController.forward().then((_) {
        if (_isRecording) {
          _handleLongPressEnd();
        }
      });
    });
  }

  void _handleLongPressEnd() {
    _longPressTimer?.cancel();
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      _borderController.reset();
      widget.onHoldEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: (_) => _handleLongPressStart(),
      onLongPressEnd: (_) => _handleLongPressEnd(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner Circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 60.r : 70.r,
            height: _isRecording ? 60.r : 70.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          // Loading Border
          SizedBox(
            width: 85.r,
            height: 85.r,
            child: AnimatedBuilder(
              animation: _borderController,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _borderController.value,
                  strokeWidth: 4.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.lightPrimary,
                  ),
                );
              },
            ),
          ),
          // Outer Ring
          Container(
            width: 85.r,
            height: 85.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.r),
            ),
          ),
        ],
      ),
    );
  }
}
