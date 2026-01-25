import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/features/auth/domain/repositories/auth_repository.dart';
import 'package:osox/features/auth/presentation/cubit/login_cubit.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:osox/features/chat/domain/repositories/chat_repository.dart';
import 'package:osox/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:osox/features/home/domain/repositories/home_repository.dart';
import 'package:osox/features/home/presentation/cubit/camera_cubit.dart';
import 'package:osox/features/home/presentation/cubit/home_cubit.dart';
import 'package:osox/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/profile/domain/repositories/profile_repository.dart';
import 'package:osox/features/profile/presentation/cubit/follow_list_cubit.dart';
import 'package:osox/features/profile/presentation/cubit/profile_cubit.dart';
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
        BlocProvider(create: (context) => LoginCubit(getIt<IAuthRepository>())),
        BlocProvider(
          create: (context) => SignUpCubit(getIt<IAuthRepository>()),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(
            getIt<IPostRepository>(),
            getIt<IProfileRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              HomeCubit(getIt<IHomeRepository>(), getIt<IPostRepository>())
                ..loadDashboard(),
        ),
        BlocProvider(
          create: (_) => FollowListCubit(getIt<IProfileRepository>()),
        ),
        BlocProvider(create: (context) => CameraCubit()),
        BlocProvider(
          create: (context) => ChatListCubit(getIt<IChatRepository>()),
        ),
      ],
      child: child,
    );
  }
}
