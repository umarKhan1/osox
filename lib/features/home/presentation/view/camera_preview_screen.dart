import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/presentation/cubit/camera_state.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:video_player/video_player.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({required this.capturedMedia, super.key});
  final CameraCaptured capturedMedia;

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.capturedMedia.isVideo) {
      _videoController =
          VideoPlayerController.file(File(widget.capturedMedia.path))
            ..initialize().then((_) {
              setState(() {});
              _videoController!.play();
              _videoController!.setLooping(true);
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _postStory() {
    final story = StoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contentUrl: widget.capturedMedia.path,
      type: widget.capturedMedia.isVideo ? StoryType.video : StoryType.image,
      duration: widget.capturedMedia.isVideo
          ? (_videoController?.value.duration ?? const Duration(seconds: 5))
          : const Duration(seconds: 5),
    );

    context.read<HomeCubit>().addStory(story);
    // Go back to home
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Preview
          Positioned.fill(
            child: widget.capturedMedia.isVideo
                ? (_videoController != null &&
                          _videoController!.value.isInitialized
                      ? Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()))
                : Image.file(
                    File(widget.capturedMedia.path),
                    fit: BoxFit.cover,
                  ),
          ),

          // Top Controls (Back)
          Positioned(
            top: 50.h,
            left: 20.w,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => context.pop(),
            ),
          ),

          // Bottom Button (Post Story)
          Positioned(
            bottom: 50.h,
            left: 20.w,
            right: 20.w,
            child: ElevatedButton(
              onPressed: _postStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // Salmon
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                'Post Story',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
