import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/constants/app_strings.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppStrings.appName.split(' ')[0], // 'Osox'
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: iconColor,
          letterSpacing: -1,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add_box_outlined, color: iconColor, size: 24.sp),
          onPressed: () => context.push('/media-selection'),
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.camera, color: iconColor, size: 22.sp),
          onPressed: () => context.push('/camera'),
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.solidPaperPlane,
            color: iconColor,
            size: 22.sp,
          ),
          onPressed: () => context.push('/messages'),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
