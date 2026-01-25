import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/home/domain/models/story_model.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/home/presentation/cubit/story_view_cubit.dart';
import 'package:osox/features/home/presentation/cubit/story_view_state.dart';
import 'package:osox/features/home/presentation/view/widgets/story_bottom_bar.dart';
import 'package:osox/features/home/presentation/view/widgets/story_management_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

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
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _startStory() {
    final cubit = context.read<StoryViewCubit>();
    final currentStory = widget.userStory.stories[cubit.state.currentIndex];

    // Mark as viewed (if not owner)
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentStory.userId != currentUserId) {
      context.read<HomeCubit>().markAsViewed(currentStory.id);
    }

    _progressController
      ..stop()
      ..reset()
      ..duration = currentStory.duration;

    if (currentStory.type == StoryType.video) {
      _chewieController?.dispose();
      _videoPlayerController?.dispose();

      final isLocalFile = currentStory.contentUrl.startsWith('/');

      _videoPlayerController = isLocalFile
          ? VideoPlayerController.file(File(currentStory.contentUrl))
          : VideoPlayerController.networkUrl(
              Uri.parse(currentStory.contentUrl),
            );

      _videoPlayerController!.initialize().then((_) {
        if (mounted) {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            showControls: false,
            aspectRatio: 9 / 16,
          );

          final duration = _videoPlayerController!.value.duration;
          _progressController.duration = duration;
          setState(() {});
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
      Navigator.of(context).pop();
    }
  }

  void _onTapLeft() {
    final cubit = context.read<StoryViewCubit>();
    if (cubit.state.currentIndex > 0) {
      cubit.previousStory();
      _startStory();
    }
  }

  void _onTapRight() {
    _onStorySegmentComplete();
  }

  Future<void> _showManagementSheet(StoryModel story) async {
    _progressController.stop();
    _chewieController?.pause();

    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryManagementSheet(story: story),
    );

    if (mounted) {
      if (deleted ?? false) {
        Navigator.of(context).pop();
      } else {
        _progressController.forward();
        _chewieController?.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryViewCubit, StoryViewState>(
      builder: (context, state) {
        final story = widget.userStory.stories[state.currentIndex];

        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < -500) {
                // Swipe Up
                final currentStory =
                    widget.userStory.stories[state.currentIndex];
                final currentUserId =
                    Supabase.instance.client.auth.currentUser?.id;
                if (currentStory.userId == currentUserId) {
                  _showManagementSheet(currentStory);
                }
              }
            },
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 2) {
                _onTapLeft();
              } else {
                _onTapRight();
              }
            },
            child: Stack(
              children: [
                // Story Content
                Positioned.fill(child: _buildStoryContent(story)),

                // Progress Bars
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8.h,
                  left: 8.w,
                  right: 8.w,
                  child: Row(
                    children: List.generate(
                      widget.userStory.stories.length,
                      (index) => Expanded(
                        child: Container(
                          height: 2.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: index < state.currentIndex
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                )
                              : index == state.currentIndex
                              ? AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    return FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _progressController.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            2.r,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Story Bottom Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Viewer indicator for owner
                      if (story.userId ==
                          Supabase.instance.client.auth.currentUser?.id)
                        GestureDetector(
                          onTap: () => _showManagementSheet(story),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                                Text(
                                  'Viewers',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const StoryBottomBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    if (story.type == StoryType.video && _chewieController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _videoPlayerController!.value.size.width,
            height: _videoPlayerController!.value.size.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }

    final isLocalFile = story.contentUrl.startsWith('/');

    return SizedBox.expand(
      child: isLocalFile
          ? Image.file(File(story.contentUrl), fit: BoxFit.cover)
          : CachedNetworkImage(
              imageUrl: story.contentUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(color: Colors.grey[800]),
              ),
              errorWidget: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
    );
  }
}
