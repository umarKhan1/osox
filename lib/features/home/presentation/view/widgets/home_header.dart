import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/constants/app_strings.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppStrings.appName.split(' ')[0], // 'Osox'
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: -1,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add_box_outlined, color: Colors.black, size: 24.sp),
          onPressed: () => context.push('/media-selection'),
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.camera, color: Colors.black, size: 22.sp),
          onPressed: () => context.push('/camera'),
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.solidPaperPlane,
            color: Colors.black,
            size: 22.sp,
          ),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
