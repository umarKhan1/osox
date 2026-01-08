import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/onboarding/presentation/cubit/onboarding_cubit.dart';
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
      ],
      child: child,
    );
  }
}
