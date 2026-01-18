import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/core/service_locator.dart';
import 'package:osox/features/auth/presentation/view/login_screen.dart';
import 'package:osox/features/auth/presentation/view/sign_up_screen.dart';
import 'package:osox/features/home/presentation/cubit/camera_state.dart';
import 'package:osox/features/home/presentation/view/camera_preview_screen.dart';
import 'package:osox/features/home/presentation/view/camera_screen.dart';
import 'package:osox/features/main/presentation/view/main_screen.dart';
import 'package:osox/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:osox/features/posts/data/repositories/post_repository.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/presentation/cubit/create_post_cubit.dart';
import 'package:osox/features/posts/presentation/cubit/location_picker_cubit.dart';
import 'package:osox/features/posts/presentation/cubit/media_picker_cubit.dart';
import 'package:osox/features/posts/presentation/view/create_post_screen.dart';
import 'package:osox/features/posts/presentation/view/location_picker_screen.dart';
import 'package:osox/features/posts/presentation/view/media_selection_screen.dart';
import 'package:osox/features/posts/presentation/view/post_detail_screen.dart';
import 'package:osox/features/splash/presentation/view/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/camera-preview',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is CameraCaptured) {
            return CameraPreviewScreen(capturedMedia: extra);
          }
          return const Scaffold(
            body: Center(child: Text('Error: No media captured')),
          );
        },
      ),
      GoRoute(
        path: '/media-selection',
        builder: (context, state) => BlocProvider(
          create: (context) => MediaPickerCubit(),
          child: const MediaSelectionScreen(),
        ),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) {
          final selectedMedia = state.extra as List<XFile>?;
          if (selectedMedia == null || selectedMedia.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No media selected')),
            );
          }
          return BlocProvider(
            create: (context) =>
                CreatePostCubit(getIt<PostRepository>(), selectedMedia),
            child: CreatePostScreen(selectedMedia: selectedMedia),
          );
        },
      ),
      GoRoute(
        path: '/location-picker',
        builder: (context, state) => BlocProvider(
          create: (context) => LocationPickerCubit(),
          child: const LocationPickerScreen(),
        ),
      ),
      GoRoute(
        path: '/post-detail',
        builder: (context, state) {
          final post = state.extra! as PostModel;
          return PostDetailScreen(post: post);
        },
      ),
    ],
  );
}
