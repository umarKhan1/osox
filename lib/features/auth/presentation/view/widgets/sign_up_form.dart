import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osox/core/constants/app_strings.dart';
import 'package:osox/core/widgets/custom_button.dart';
import 'package:osox/core/widgets/custom_text_field.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_state.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: AppStrings.fullName,
              hintText: AppStrings.fullNameHint,
              icon: FontAwesomeIcons.user,
              controller: _fullNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Full Name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            CustomTextField(
              label: AppStrings.email,
              hintText: AppStrings.emailHint,
              icon: FontAwesomeIcons.envelope,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                final isPasswordVisible = state.isPasswordVisible;
                return CustomTextField(
                  label: AppStrings.password,
                  hintText: AppStrings.passwordHint,
                  icon: FontAwesomeIcons.lock,
                  isPassword: true,
                  obscureText: !isPasswordVisible,
                  controller: _passwordController,
                  onToggleVisibility: () {
                    context.read<SignUpCubit>().togglePasswordVisibility();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 24.h),
            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                final isConfirmPasswordVisible = state.isConfirmPasswordVisible;
                return CustomTextField(
                  label: AppStrings.confirmPassword,
                  hintText: AppStrings.confirmPasswordHint,
                  icon: FontAwesomeIcons.lock,
                  isPassword: true,
                  obscureText: !isConfirmPasswordVisible,
                  controller: _confirmPasswordController,
                  onToggleVisibility: () {
                    context
                        .read<SignUpCubit>()
                        .toggleConfirmPasswordVisibility();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password is required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 48.h),
            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                return CustomButton(
                  text: AppStrings.signUp,
                  textColor: Colors.white,
                  onPressed: state is SignUpLoading
                      ? () {}
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<SignUpCubit>().signUp(
                              _fullNameController.text,
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
