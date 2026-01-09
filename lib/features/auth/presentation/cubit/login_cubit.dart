import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginInitial());

  void togglePasswordVisibility() {
    if (state is LoginInitial) {
      final currentState = state as LoginInitial;
      emit(
        currentState.copyWith(
          isPasswordVisible: !currentState.isPasswordVisible,
        ),
      );
    }
  }

  void toggleRememberMe({required bool value}) {
    if (state is LoginInitial) {
      final currentState = state as LoginInitial;
      emit(currentState.copyWith(rememberMe: value));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    try {
      // Simulating API call
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
