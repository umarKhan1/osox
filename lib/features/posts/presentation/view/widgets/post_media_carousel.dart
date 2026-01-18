import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

class PostMediaCarousel extends StatefulWidget {
  const PostMediaCarousel({required this.post, super.key});

  final PostModel post;

  @override
  State<PostMediaCarousel> createState() => _PostMediaCarouselState();
}

class _PostMediaCarouselState extends State<PostMediaCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1, // Instagram standard square aspect ratio
          child: PageView.builder(
            itemCount: widget.post.mediaPaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final path = widget.post.mediaPaths[index];
              final isNetwork = path.startsWith('http');

              return isNetwork
                  ? Image.network(
                      path,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    )
                  : Image.file(File(path), fit: BoxFit.cover);
            },
          ),
        ),

        // Multi-image indicator (e.g., 1/3)
        if (widget.post.mediaPaths.length > 1)
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.post.mediaPaths.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Dot indicator
        if (widget.post.mediaPaths.length > 1)
          Positioned(
            bottom: -20.h, // We'll handle this in the parent PostCard usually,
            // but let's keep it here for now if needed.
            // Actually, Instagram puts dots BELOW the media.
            // I'll adjust the PostCard to handle this.
            left: 0,
            right: 0,
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class PostPageIndicator extends StatelessWidget {
  const PostPageIndicator({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          width: 6.w,
          height: 6.w,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index ? Colors.blue : Colors.grey[400],
          ),
        );
      }),
    );
  }
}
