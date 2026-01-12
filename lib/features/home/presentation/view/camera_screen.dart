import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/home/presentation/cubit/camera_cubit.dart';
import 'package:osox/features/home/presentation/cubit/camera_state.dart';
import 'package:osox/features/home/presentation/view/widgets/camera_capture_button.dart';
import 'package:osox/features/home/presentation/view/widgets/filter_selector.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _selectedFilterIndex = 0;

  // Filter presets
  static final List<ColorFilter?> _filters = [
    null, // No filter
    const ColorFilter.matrix([
      0.393,
      0.769,
      0.189,
      0,
      0,
      0.349,
      0.686,
      0.168,
      0,
      0,
      0.272,
      0.534,
      0.131,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]), // Sepia
    const ColorFilter.matrix([
      0.33,
      0.33,
      0.33,
      0,
      0,
      0.33,
      0.33,
      0.33,
      0,
      0,
      0.33,
      0.33,
      0.33,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]), // Grayscale
    ColorFilter.mode(
      Colors.blue.withValues(alpha: 0.2),
      BlendMode.overlay,
    ), // Cool
    ColorFilter.mode(
      Colors.orange.withValues(alpha: 0.2),
      BlendMode.overlay,
    ), // Warm
    const ColorFilter.matrix([
      1.5,
      0,
      0,
      0,
      0,
      0,
      1.5,
      0,
      0,
      0,
      0,
      0,
      1.5,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]), // Bright
  ];

  @override
  void initState() {
    super.initState();
    context.read<CameraCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CameraCubit, CameraState>(
        listener: (context, state) {
          if (state is CameraCaptured && context.mounted) {
            context.push('/camera-preview', extra: state).then((_) {
              if (context.mounted) {
                // Re-initialize or reset camera when coming back
                context.read<CameraCubit>().reset();
              }
            });
          }
        },
        builder: (context, state) {
          if (state is CameraLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CameraError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is CameraReady || state is CameraCapturing) {
            final controller = state is CameraReady
                ? state.controller
                : (state as CameraCapturing).controller;

            return Stack(
              children: [
                // Camera Preview with Filter
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: _filters[_selectedFilterIndex] != null
                        ? ColorFiltered(
                            colorFilter: _filters[_selectedFilterIndex]!,
                            child: CameraPreview(controller),
                          )
                        : CameraPreview(controller),
                  ),
                ),

                // Top Controls (Cancel Icon)
                Positioned(
                  top: 50.h,
                  left: 20.w,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),

                // Bottom Controls
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Filter Selector (Above the button)
                      FilterSelector(
                        onFilterChanged: (index) {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                      ),
                      SizedBox(height: 15.h),
                      // Capture Button
                      CameraCaptureButton(
                        onTap: () => context.read<CameraCubit>().takePicture(),
                        onHoldStart: () =>
                            context.read<CameraCubit>().startVideoRecording(),
                        onHoldEnd: () =>
                            context.read<CameraCubit>().stopVideoRecording(),
                      ),
                      SizedBox(height: 15.h),
                      // Mode Selector (POST, STORY, REELS, LIVE)
                      Text(
                        'STORY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
