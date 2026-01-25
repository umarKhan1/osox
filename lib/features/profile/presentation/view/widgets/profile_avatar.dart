import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.imageUrl,
    this.hasStory = false,
    this.onTap,
    super.key,
  });

  final String imageUrl;
  final bool hasStory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(hasStory ? 3.r : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasStory
              ? const LinearGradient(
                  colors: [Colors.purple, Colors.orange, Colors.yellow],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          border: !hasStory ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: Container(
          padding: EdgeInsets.all(hasStory ? 2.r : 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 40.r,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageUrl.isNotEmpty
                ? CachedNetworkImageProvider(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? Icon(Icons.person, size: 40.r, color: Colors.grey)
                : null,
          ),
        ),
      ),
    );
  }
}
