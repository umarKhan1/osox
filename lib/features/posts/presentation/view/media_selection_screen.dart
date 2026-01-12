import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/core/constants/app_colors.dart';
import 'package:osox/features/posts/presentation/cubit/media_picker_cubit.dart';
import 'package:osox/features/posts/presentation/cubit/media_picker_state.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class MediaSelectionScreen extends StatefulWidget {
  const MediaSelectionScreen({super.key});

  @override
  State<MediaSelectionScreen> createState() => _MediaSelectionScreenState();
}

class _MediaSelectionScreenState extends State<MediaSelectionScreen> {
  final PageController _pageController = PageController();
  final Map<String, VideoPlayerController> _videoControllers =
      {}; // Changed to use asset ID
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<MediaPickerCubit>().loadMedia();
    _pageController.addListener(_onPageChanged);
  }

  void _cleanupVideoControllers() {
    // Pause and dispose all video controllers
    for (final controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
      controller.dispose();
    }
    _videoControllers.clear();
    _currentPage = 0;
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      // Pause all videos
      for (final controller in _videoControllers.values) {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      }
      _currentPage = page;
      setState(() {}); // Rebuild to play new page's video
    }
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onPageChanged)
      ..dispose();
    // Pause and dispose all video controllers
    for (final controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  Future<VideoPlayerController> _getVideoController(AssetEntity asset) async {
    if (_videoControllers.containsKey(asset.id)) {
      return _videoControllers[asset.id]!;
    }

    final file = await asset.file;
    final controller = VideoPlayerController.file(File(file!.path));
    await controller.initialize();
    await controller.setLooping(true);
    _videoControllers[asset.id] = controller;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16.sp,
            ),
          ),
        ),
        leadingWidth: 80.w,
        title: Text(
          'Recents',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          BlocBuilder<MediaPickerCubit, MediaPickerState>(
            builder: (context, state) {
              final hasMedia =
                  state is MediaPickerLoaded &&
                  state.selectedIndices.isNotEmpty;
              return TextButton(
                onPressed: hasMedia
                    ? () async {
                        // Stop all playing videos before navigating
                        for (final controller in _videoControllers.values) {
                          if (controller.value.isPlaying) {
                            await controller.pause();
                          }
                        }

                        final mediaState = state;
                        // Convert AssetEntity to XFile with error handling
                        try {
                          final xFiles = <XFile>[];
                          for (final asset in mediaState.selectedAssets) {
                            final file = await asset.file;
                            if (file != null) {
                              xFiles.add(XFile(file.path));
                            }
                          }

                          if (xFiles.isNotEmpty && context.mounted) {
                            await context.push('/create-post', extra: xFiles);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error loading media: $e'),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: hasMedia
                        ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary)
                        : Colors.grey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Media Preview with PageView
          Expanded(
            flex: 3,
            child: BlocBuilder<MediaPickerCubit, MediaPickerState>(
              key: const ValueKey('media_preview'),
              builder: (context, state) {
                if (state is MediaPickerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MediaPickerLoaded &&
                    state.selectedIndices.isNotEmpty) {
                  final selectedList = state.selectedIndices.toList();
                  return Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: selectedList.length,
                        itemBuilder: (context, pageIndex) {
                          final assetIndex = selectedList[pageIndex];
                          final asset = state.mediaAssets[assetIndex];

                          if (asset.type == AssetType.video) {
                            return FutureBuilder<VideoPlayerController>(
                              future: _getVideoController(asset),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final controller = snapshot.data!;
                                  // Only play if this is the current page
                                  if (pageIndex == _currentPage &&
                                      !controller.value.isPlaying) {
                                    controller.play();
                                  } else if (pageIndex != _currentPage &&
                                      controller.value.isPlaying) {
                                    controller.pause();
                                  }
                                  return Center(
                                    child: AspectRatio(
                                      aspectRatio: controller.value.aspectRatio,
                                      child: VideoPlayer(controller),
                                    ),
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          }

                          // Image preview
                          return FutureBuilder<Uint8List?>(
                            future: asset.thumbnailDataWithSize(
                              const ThumbnailSize(800, 800),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Center(
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                        },
                      ),
                      // Page indicator
                      if (selectedList.length > 1)
                        Positioned(
                          top: 16.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              selectedList.length,
                              (index) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return Container(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  child: Center(
                    child: Text(
                      'Select a photo or video',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Tabs
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: BlocBuilder<MediaPickerCubit, MediaPickerState>(
              builder: (context, state) {
                final currentType = state is MediaPickerLoaded
                    ? state.currentMediaType
                    : MediaType.all;
                return Row(
                  children: [
                    Expanded(
                      child: _buildTab(
                        'Library',
                        currentType == MediaType.all,
                        () {
                          _cleanupVideoControllers();
                          context.read<MediaPickerCubit>().changeMediaType(
                            MediaType.all,
                          );
                        },
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildTab(
                        'Photo',
                        currentType == MediaType.image,
                        () {
                          _cleanupVideoControllers();
                          context.read<MediaPickerCubit>().changeMediaType(
                            MediaType.image,
                          );
                        },
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildTab(
                        'Video',
                        currentType == MediaType.video,
                        () {
                          _cleanupVideoControllers();
                          context.read<MediaPickerCubit>().changeMediaType(
                            MediaType.video,
                          );
                        },
                        isDark,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Gallery Grid
          Expanded(
            flex: 2,
            child: BlocBuilder<MediaPickerCubit, MediaPickerState>(
              builder: (context, state) {
                if (state is MediaPickerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MediaPickerError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  );
                }

                if (state is MediaPickerLoaded) {
                  return GridView.builder(
                    padding: EdgeInsets.all(2.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2.w,
                      mainAxisSpacing: 2.w,
                    ),
                    itemCount: state.mediaAssets.length,
                    itemBuilder: (context, index) {
                      final asset = state.mediaAssets[index];
                      final isSelected = state.selectedIndices.contains(index);
                      final selectionNumber = isSelected
                          ? state.selectedIndices.toList().indexOf(index) + 1
                          : 0;

                      return GestureDetector(
                        onTap: () {
                          context.read<MediaPickerCubit>().toggleSelection(
                            index,
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Thumbnail
                            FutureBuilder<Uint8List?>(
                              future: asset.thumbnailDataWithSize(
                                const ThumbnailSize(200, 200),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                );
                              },
                            ),

                            // Video indicator
                            if (asset.type == AssetType.video)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        _formatDuration(asset.duration),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Selection indicator
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$selectionNumber',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String label,
    bool isActive,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    // ignore: lines_longer_than_80_chars
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
