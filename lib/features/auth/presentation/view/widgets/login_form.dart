import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osox/core/constants/app_strings.dart';
import 'package:osox/core/widgets/custom_button.dart';
import 'package:osox/core/widgets/custom_text_field.dart';
import 'package:osox/features/auth/presentation/cubit/login_cubit.dart';
import 'package:osox/features/auth/presentation/cubit/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
            SizedBox(height: 28.h),
            BlocBuilder<LoginCubit, LoginState>(
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
                    context.read<LoginCubit>().togglePasswordVisibility();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        final rememberMe = state.rememberMe;
                        return SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: Checkbox(
                            value: rememberMe,
                            activeColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            onChanged: (value) {
                              context.read<LoginCubit>().toggleRememberMe(
                                value: value ?? false,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppStrings.rememberMe,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48.h),
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return CustomButton(
                  text: AppStrings.login,
                  textColor: Colors.white, // White text for salmon background
                  onPressed: state is LoginLoading
                      ? () {}
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<LoginCubit>().login(
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
