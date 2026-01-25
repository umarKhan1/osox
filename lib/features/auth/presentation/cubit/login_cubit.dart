import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/auth/domain/repositories/auth_repository.dart';
import 'package:osox/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginInitial());

  final IAuthRepository _authRepository;

  void togglePasswordVisibility() {
    final newState = state is LoginFailure
        ? LoginInitial(
            isPasswordVisible: !state.isPasswordVisible,
            rememberMe: state.rememberMe,
          )
        : state.copyWith(isPasswordVisible: !state.isPasswordVisible);
    emit(newState);
  }

  void toggleRememberMe({required bool value}) {
    final newState = state is LoginFailure
        ? LoginInitial(
            isPasswordVisible: state.isPasswordVisible,
            rememberMe: value,
          )
        : state.copyWith(rememberMe: value);
    emit(newState);
  }

  Future<void> login(String email, String password) async {
    emit(
      LoginLoading(
        isPasswordVisible: state.isPasswordVisible,
        rememberMe: state.rememberMe,
      ),
    );
    try {
      await _authRepository.signIn(email: email, password: password);
      emit(
        LoginSuccess(
          isPasswordVisible: state.isPasswordVisible,
          rememberMe: state.rememberMe,
        ),
      );
    } catch (e) {
      emit(
        LoginFailure(
          e.toString(),
          isPasswordVisible: state.isPasswordVisible,
          rememberMe: state.rememberMe,
        ),
      );
    }
  }
}
