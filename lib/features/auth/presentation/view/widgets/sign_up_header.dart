import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/core/constants/app_assets.dart';
import 'package:osox/features/auth/presentation/view/widgets/sign_up_title.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Image.asset(
          AppAssets.topheader,
          width: double.infinity,
          height: 380.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 380.h,
              color: theme.primaryColor.withValues(alpha: 0.1),
            );
          },
        ),
        Positioned(bottom: 40.h, left: 24.w, child: const SignUpTitle()),
      ],
    );
  }
}
