import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {
  const SignUpInitial({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  @override
  List<Object?> get props => [isPasswordVisible, isConfirmPasswordVisible];

  SignUpInitial copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpInitial(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

class SignUpLoading extends SignUpState {
  const SignUpLoading();
}

class SignUpSuccess extends SignUpState {
  const SignUpSuccess();
}

class SignUpFailure extends SignUpState {
  const SignUpFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
