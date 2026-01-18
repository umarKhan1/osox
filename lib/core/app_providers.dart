import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/features/auth/presentation/cubit/login_cubit.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:osox/features/home/data/repositories/home_repository.dart';
import 'package:osox/features/home/presentation/cubit/camera_cubit.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:osox/features/posts/data/repositories/post_repository.dart';
import 'package:osox/features/splash/presentation/cubit/splash_cubit.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => OnboardingCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => SignUpCubit()),
        BlocProvider(
          create: (context) =>
              HomeCubit(HomeRepository(), getIt<PostRepository>())
                ..loadDashboard(),
        ),
        BlocProvider(create: (context) => CameraCubit()),
      ],
      child: child,
    );
  }
}
