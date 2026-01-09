import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/auth/presentation/cubit/sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(const SignUpInitial());

  void togglePasswordVisibility() {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(
        currentState.copyWith(
          isPasswordVisible: !currentState.isPasswordVisible,
        ),
      );
    }
  }

  void toggleConfirmPasswordVisibility() {
    if (state is SignUpInitial) {
      final currentState = state as SignUpInitial;
      emit(
        currentState.copyWith(
          isConfirmPasswordVisible: !currentState.isConfirmPasswordVisible,
        ),
      );
    }
  }

  Future<void> signUp(String fullName, String email, String password) async {
    emit(const SignUpLoading());
    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }
}
