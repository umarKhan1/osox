import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/presentation/cubit/story_view_cubit.dart';
import 'package:osox/features/home/presentation/cubit/story_view_state.dart';
import 'package:osox/features/home/presentation/view/widgets/story_bottom_bar.dart';
import 'package:osox/features/home/presentation/view/widgets/story_viewer_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({required this.userStory, super.key});

  final UserStoriesModel userStory;

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this)
      ..addListener(() {
        if (mounted) {
          context.read<StoryViewCubit>().updateProgress(
            _progressController.value,
          );
        }
      });
    _startStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _startStory() {
    final cubit = context.read<StoryViewCubit>();
    final currentStory = widget.userStory.stories[cubit.state.currentIndex];

    _progressController
      ..stop()
      ..reset()
      ..duration = currentStory.duration;

    if (currentStory.type == StoryType.video) {
      _videoController?.dispose();

      // Check if it's a local file path or network URL
      final isLocalFile = currentStory.contentUrl.startsWith('/');

      _videoController = isLocalFile
          ? VideoPlayerController.file(File(currentStory.contentUrl))
          : VideoPlayerController.networkUrl(
              Uri.parse(currentStory.contentUrl),
            );

      _videoController!.initialize().then((_) {
        if (mounted) {
          // Sync progress bar duration with actual video duration
          _progressController.duration = _videoController!.value.duration;
          setState(() {});
          _videoController!.play();
          _progressController.forward().then((_) {
            if (mounted) {
              _onStorySegmentComplete();
            }
          });
        }
      });
    } else {
      _progressController.forward().then((_) {
        if (mounted) {
          _onStorySegmentComplete();
        }
      });
    }
  }

  void _onStorySegmentComplete() {
    final cubit = context.read<StoryViewCubit>();
    if (cubit.state.currentIndex < widget.userStory.stories.length - 1) {
      cubit.nextStory(widget.userStory.stories.length);
      _startStory();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _showViewerSheet(StoryModel story) {
    _progressController.stop(); // Pause while viewing sheet
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: StoryViewerSheet(story: story),
      ),
    ).then((_) {
      _progressController.forward(); // Resume
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          BlocBuilder<StoryViewCubit, StoryViewState>(
            builder: (context, state) {
              final story = widget.userStory.stories[state.currentIndex];
              if (story.type == StoryType.video &&
                  _videoController != null &&
                  _videoController!.value.isInitialized) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                );
              }

              // Check if it's a local file path or network URL
              final isLocalFile = story.contentUrl.startsWith('/');

              return Center(
                child: isLocalFile
                    ? Image.file(
                        File(story.contentUrl),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : CachedNetworkImage(
                        imageUrl: story.contentUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
              );
            },
          ),

          // Stepper (Progress bars)
          Positioned(
            top: 50.h,
            left: 8.w,
            right: 8.w,
            child: BlocBuilder<StoryViewCubit, StoryViewState>(
              builder: (context, state) {
                return Row(
                  children: List.generate(
                    widget.userStory.stories.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.r),
                          child: LinearProgressIndicator(
                            value: index < state.currentIndex
                                ? 1.0
                                : (index == state.currentIndex
                                      ? state.progress
                                      : 0.0),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                            minHeight: 2.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Bar
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StoryBottomBar(),
          ),

          // User Info
          Positioned(
            top: 70.h,
            left: 16.w,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.userStory.user.profileUrl,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.userStory.user.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          // Close Button
          Positioned(
            top: 70.h,
            right: 16.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Gesture Detectors for navigation and viewer sheet
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // Only allow drag-up for "Your Story"
              if (details.delta.dy < -10 &&
                  widget.userStory.user.name == 'Your Story') {
                final state = context.read<StoryViewCubit>().state;
                _showViewerSheet(widget.userStory.stories[state.currentIndex]);
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final cubit = context.read<StoryViewCubit>();
                      if (cubit.state.currentIndex > 0) {
                        cubit.previousStory();
                        _startStory();
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final cubit = context.read<StoryViewCubit>();
                      if (cubit.state.currentIndex <
                          widget.userStory.stories.length - 1) {
                        cubit.nextStory(widget.userStory.stories.length);
                        _startStory();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
