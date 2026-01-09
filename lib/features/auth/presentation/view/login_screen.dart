import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [LoginHeader(), LoginForm(), LoginFooter()],
          ),
        ),
      ),
    );
  }
}
