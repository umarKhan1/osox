import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/auth/domain/repositories/auth_repository.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authRepository) : super(const SignUpInitial());

  final IAuthRepository _authRepository;

  void togglePasswordVisibility() {
    final newState = state is SignUpFailure
        ? SignUpInitial(
            isPasswordVisible: !state.isPasswordVisible,
            isConfirmPasswordVisible: state.isConfirmPasswordVisible,
          )
        : state.copyWith(isPasswordVisible: !state.isPasswordVisible);
    emit(newState);
  }

  void toggleConfirmPasswordVisibility() {
    final newState = state is SignUpFailure
        ? SignUpInitial(
            isPasswordVisible: state.isPasswordVisible,
            isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
          )
        : state.copyWith(
            isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
          );
    emit(newState);
  }

  Future<void> signUp(String fullName, String email, String password) async {
    emit(
      SignUpLoading(
        isPasswordVisible: state.isPasswordVisible,
        isConfirmPasswordVisible: state.isConfirmPasswordVisible,
      ),
    );
    try {
      await _authRepository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      emit(
        SignUpSuccess(
          isPasswordVisible: state.isPasswordVisible,
          isConfirmPasswordVisible: state.isConfirmPasswordVisible,
        ),
      );
    } catch (e) {
      emit(
        SignUpFailure(
          e.toString(),
          isPasswordVisible: state.isPasswordVisible,
          isConfirmPasswordVisible: state.isConfirmPasswordVisible,
        ),
      );
    }
  }
}
