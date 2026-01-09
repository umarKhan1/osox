import 'package:go_router/go_router.dart';
import 'package:osox/features/auth/presentation/view/login_screen.dart';
import 'package:osox/features/auth/presentation/view/sign_up_screen.dart';
import 'package:osox/features/onboarding/presentation/view/onboarding_screen.dart';
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
    ],
  );
}
