import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account Created Successfully!')),
            );
            context.go('/home');
          } else if (state is SignUpFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SignUpHeader(), SignUpForm(), SignUpFooter()],
          ),
        ),
      ),
    );
  }
}
