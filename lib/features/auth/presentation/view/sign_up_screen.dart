import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/widgets/global_error_dialog.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_state.dart';
import 'package:osox/features/auth/presentation/view/widgets/sign_up_footer.dart';
import 'package:osox/features/auth/presentation/view/widgets/sign_up_form.dart';
import 'package:osox/features/auth/presentation/view/widgets/sign_up_header.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            context.go('/home');
          } else if (state is SignUpFailure) {
            GlobalErrorDialog.show(context, message: state.error);
          }
        },
        child: Stack(
          children: [
            const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [SignUpHeader(), SignUpForm(), SignUpFooter()],
              ),
            ),
            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                if (state is SignUpLoading) {
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
