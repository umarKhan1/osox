import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/widgets/global_error_dialog.dart';
import 'package:osox/features/auth/presentation/cubit/login_cubit.dart';
import 'package:osox/features/auth/presentation/cubit/login_state.dart';
import 'package:osox/features/auth/presentation/view/widgets/login_footer.dart';
import 'package:osox/features/auth/presentation/view/widgets/login_form.dart';
import 'package:osox/features/auth/presentation/view/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.go('/home');
          } else if (state is LoginFailure) {
            GlobalErrorDialog.show(context, message: state.error);
          }
        },
        child: Stack(
          children: [
            const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [LoginHeader(), LoginForm(), LoginFooter()],
              ),
            ),
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                if (state is LoginLoading) {
                  return ColoredBox(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
